Ryan.UI = {
    -- General UI --
    CreateSavableChoiceWithDefault = function(root, menu_name, command_name, player_name, description, choices, on_update)
		local state = choices[1]
		local state_change = 2147483647
		local state_values = {[state] = true}

		local choices_root = menu.list(root, menu_name:gsub("%%", state), {command_name}, description)
		for _, choice in pairs(choices) do
			menu.toggle(choices_root, choice, {command_name .. Ryan.Basics.CommandName(choice)}, "", function(value)
                if value and choice ~= state then
                    menu.trigger_commands(command_name .. Ryan.Basics.CommandName(state) .. player_name .. " off")
                    menu.set_menu_name(choices_root, menu_name:gsub("%%", choice))
                    state = choice
                    on_update(state)
				end
                state_values[choice] = value
				state_change = util.current_time_millis()
			end, choice == choices[1])
		end

		util.create_tick_handler(function()
			if util.current_time_millis() - state_change > 500 then
				local has_choice = false
				for _, choice in pairs(choices) do
					if state_values[choice] then has_choice = true end
				end
				if not has_choice then
                    menu.trigger_commands(command_name .. Ryan.Basics.CommandName(choices[1]) .. player_name .. " on")
                end
			end
		end)

		on_update(state)
		return choices_root
	end,

	CreateEffectChoice = function(root, command_prefix, player_name, effects, effect_name, effect_description, options, god_finger)
        local command = command_prefix .. Ryan.Basics.CommandName(effect_name)

        if god_finger then
            local effect_root = menu.list(root, effect_name .. "...", {command}, effect_description)
            for _, choice in pairs(options) do
                if effects[Ryan.Basics.ToTableName(effect_name)] == nil then effects[Ryan.Basics.ToTableName(effect_name)] = {} end

                Ryan.UI.CreateSavableChoiceWithDefault(effect_root, choice .. ": %", command .. Ryan.Basics.CommandName(choice), "", "", Ryan.UI.GodFingerActivationModes, function(value)
                    effects[Ryan.Basics.ToTableName(effect_name)][Ryan.Basics.ToTableName(choice)] = value
                end)
            end
        else
            local effect_root = menu.list(root, effect_name .. ": -", {command}, effect_description)
            for _, choice in pairs(options) do
                menu.toggle(effect_root, choice, {command .. Ryan.Basics.CommandName(choice)}, "", function(value)
                    if value then
                        for _, other_choice in pairs(options) do
                            if other_choice ~= choice then
                                menu.trigger_commands(command .. Ryan.Basics.CommandName(other_choice) .. player_name .. " off")
                            end
                        end
                        util.yield(500)
                        effects[Ryan.Basics.ToTableName(effect_name)] = Ryan.Basics.ToTableName(choice)
                        menu.set_menu_name(effect_root, effect_name .. ": " .. choice)
                    else
                        effects[Ryan.Basics.ToTableName(effect_name)] = nil
                        menu.set_menu_name(effect_root, effect_name .. ": -")
                    end
                end)
            end
        end
    end,

    CreateEffectToggle = function(root, command_prefix, effects, effect_name, effect_description, god_finger)
        if god_finger then
            Ryan.UI.CreateSavableChoiceWithDefault(root, effect_name .. ": %", command_prefix .. Ryan.Basics.CommandName(effect_name), "", effect_description, Ryan.UI.GodFingerActivationModes, function(value)
                effects[Ryan.Basics.ToTableName(effect_name)] = value
            end)
        else
            menu.toggle(root, effect_name, {command_prefix .. Ryan.Basics.CommandName(effect_name)}, effect_description, function(value)
                effects[Ryan.Basics.ToTableName(effect_name)] = value
            end)
        end
    end,

    CreateTeleportList = function(root, name, coordinates)
        for i = 1, #coordinates do
            local draw_beacon = false
            local teleport = menu.action(root, name .. " " .. i, {"ryan" .. Ryan.Basics.CommandName(name) .. i}, "Teleport to " .. name .. " #" .. i .. ".", function()
                Ryan.Basics.Teleport({x = coordinates[i][1], y = coordinates[i][2], z = coordinates[i][3]}, false)
            end)
            menu.on_focus(teleport, function() draw_beacon = true end)
            menu.on_blur(teleport, function() draw_beacon = false end)
        end
        util.create_tick_handler(function()
            if draw_beacon then util.draw_ar_beacon(coordinates) end
        end)
    end,


    -- God Finger UI --
    GodFingerActivationModes = {
        "Off",
        "Look",
        "Hold Q",
        "Hold E",
        "Hold R",
        "Hold F",
        "Hold C",
        "Hold X",
        "Hold Z"
    },

	GetGodFingerActivation = function(key)
		if key == "Look"       then return 1
		elseif key == "Hold Q" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.Cover) and 2 or 0
		elseif key == "Hold E" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.VehicleHorn) and 2 or 0
		elseif key == "Hold R" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.Reload) and 2 or 0
		elseif key == "Hold F" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.Enter) and 2 or 0
		elseif key == "Hold C" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.LookBehind) and 2 or 0
		elseif key == "Hold X" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.VehicleDuck) and 2 or 0
		elseif key == "Hold Z" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.HudSpecial) and 2 or 0
		else                   return 0 end
	end,

	GetGodFingerKeybinds = function(effects)
		function icon(mode)
			if mode == "Hold Q"     then return "~INPUT_COVER~"
			elseif mode == "Hold E" then return "~INPUT_VEH_HORN~"
			elseif mode == "Hold R" then return "~INPUT_RELOAD~"
			elseif mode == "Hold F" then return "~INPUT_ENTER~"
			elseif mode == "Hold C" then return "~INPUT_LOOK_BEHIND~"
			elseif mode == "Hold X" then return "~INPUT_VEH_DUCK~"
			elseif mode == "Hold Z" then return "~INPUT_HUD_SPECIAL~" end
    	end

		function split(help, new_help)
			local help_line = help:sub(1 - (help:reverse():find("\n") or 0))
			local help_line_length = help_line:gsub("~[A-Z_]+~", ""):gsub("   ", ""):len()
			local new_help_length = new_help:gsub("~[A-Z_]+~", ""):gsub("   ", ""):len()
			if help_line_length + new_help_length >= 28 then return "\n" .. new_help
			else return (help_line_length > 0 and "   " or "") .. new_help end
		end

		help = ""

		for effect, value in pairs(effects) do
			if type(value) == "table" then
				for choice, mode in pairs(value) do
					if mode:find("Hold") then
						help = help .. split(help, icon(mode) .. " " .. Ryan.Basics.FromTableName(effect) .. ": " .. Ryan.Basics.FromTableName(choice))
					end
				end
			else
				if value:find("Hold") then
					help = help .. split(help, icon(value) .. " " .. Ryan.Basics.FromTableName(effect))
				end
			end
		end

    	return help
	end,

    DisableGodFingerKeybinds = function()
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.Cover, true)                  -- Q
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleRadioWheel, true)      -- Q
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleHorn, true)            -- E
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.Reload, true)                 -- R
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.MeleeAttackLight, true)       -- R
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleCinematicCamera, true) -- R
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.Enter, true)                  -- F
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleExit, true)            -- F
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.LookBehind, true)             -- C
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleLookBehind, true)      -- C
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleDuck, true)            -- X
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.MultiplayerInfo, true)        -- Z
        PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.HudSpecial, true)             -- Z
	end,

    ParseEffectList = function(effects, god_finger)
        local parsed = {}
        for effect, value in pairs(effects) do
            if god_finger then
                if type(value) == "table" then
                    if parsed[effect] == nil then parsed[effect] = {} end
                    for choice, mode in pairs(value) do
                        parsed[effect][choice] = Ryan.UI.GetGodFingerActivation(mode) > 0
                    end
                else
                    parsed[effect] = Ryan.UI.GetGodFingerActivation(value) > 0
                end
            else
                if type(value) == "boolean" then
                    parsed[effect] = value
                else
                    if parsed[effect] == nil then parsed[effect] = {} end
                    parsed[effect][value] = true
                end
            end
        end
        return parsed
    end,


    -- NPC Effects UI --
    CreateNPCEffectList = function(root, command_prefix, effects, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, "", effects, "Scenario", "Change the NPC's current scenario.", {"Musician", "Janitor", "Paparazzi", "Human Statue"}, god_finger)
        Ryan.UI.CreateEffectToggle(root, command_prefix, effects, "Nude", "Make the NPC nude.", god_finger)
        Ryan.UI.CreateEffectToggle(root, command_prefix, effects, "Flee", "Make the NPC flee you.", god_finger)
        Ryan.UI.CreateEffectToggle(root, command_prefix, effects, "Ragdoll", "Make the NPC ragdoll.", god_finger)
        Ryan.UI.CreateEffectToggle(root, command_prefix, effects, "Delete", "Delete the NPC.", god_finger)
    end,

    ApplyNPCEffectList = function(npc, effects, state, god_finger)
        if state[npc] == nil then state[npc] = {} end
        local parsed = Ryan.UI.ParseEffectList(effects, god_finger)

        if parsed.scenario and parsed.scenario.musician and state[npc].scenario ~= "musician" then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
            TASK.TASK_START_SCENARIO_IN_PLACE(npc, "WORLD_HUMAN_MUSICIAN", 0, false)
            state[npc].scenario = "musician"
        end
        if parsed.scenario and parsed.scenario.janitor and state[npc].scenario ~= "janitor" then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
            TASK.TASK_START_SCENARIO_IN_PLACE(npc, "WORLD_HUMAN_JANITOR", 0, false)
            state[npc].scenario = "janitor"
        end
        if parsed.scenario and parsed.scenario.paparazzi and state[npc].scenario ~= "paparazzi" then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
            TASK.TASK_START_SCENARIO_IN_PLACE(npc, "WORLD_HUMAN_PAPARAZZI", 0, false)
            state[npc].scenario = "paparazzi"
        end
        if parsed.scenario and parsed.scenario.human_statue and state[npc].scenario ~= "human_statue" then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            TASK.TASK_START_SCENARIO_IN_PLACE(ped, "WORLD_HUMAN_HUMAN_STATUE", 0, false)
            state[npc].scenario = "human_statue"
        end

        if parsed.nude and not state[npc].nude then
            if god_finger or math.random(1, 25) == 1 then
                Ryan.Basics.RequestModel(util.joaat("a_f_y_topless_01"))

                local coords = ENTITY.GET_ENTITY_COORDS(npc)
                local heading = ENTITY.GET_ENTITY_HEADING(npc)
                
                entities.delete_by_handle(npc)
                npc = entities.create_ped(0, util.joaat("a_f_y_topless_01"), coords, heading)
                state[npc] = {}

                PED.SET_PED_COMPONENT_VARIATION(npc, 8, 1, -1, 0)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
                TASK.TASK_WANDER_STANDARD(npc, 10.0, 10)
            end
            state[npc].nude = true
        end

        if parsed.flee and not state[npc].flee then
            TASK.TASK_SMART_FLEE_PED(npc, Ryan.Player.Self().ped_id, 500.0, -1, false, false)
            PED.SET_PED_KEEP_TASK(npc, true)
            state[npc].flee = true
        end

        if parsed.ragdoll then
            PED.SET_PED_TO_RAGDOLL(npc, 1000, 1000, 0, 0, 0, 0)
        end

        if parsed.delete then
            entities.delete_by_handle(npc)
        end
    end,


    -- Vehicle Effects UI --
    CreateVehicleEffectList = function(root, command_prefix, player_name, effects, enable_risky, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Speed", "Change the speed of the vehicle.", {"Fast", "Slow", "Normal"}, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Grip", "Change the grip of the vehicle's tires.", {"None", "Normal"}, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Doors", "Change the vehicle's door lock state.", {"Lock", "Unlock"}, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Tires", "Change the vehicle's tire health.", {"Burst", "Fix"}, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Engine", "Change the vehicle's engine health.", {"Kill", "Fix"}, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Upgrades", "Change the vehicle's upgrades.", {"All", "None"}, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Godmode", "Change the vehicle's upgrades.", {"On", "Off"}, god_finger)
        Ryan.UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Gravity", "Change the vehicle's gravity.", {"None", "Normal"}, god_finger)
        Ryan.UI.CreateEffectToggle(root, command_prefix, effects, "Theft Alarm", "Trigger the vehicle's theft alarm.", god_finger)
        Ryan.UI.CreateEffectToggle(root, command_prefix, effects, "Catapult", "Catapult the vehicle non-stop.", god_finger)
        Ryan.UI.CreateEffectToggle(root, command_prefix, effects, "Delete", "Delete the vehicle.", god_finger)
    end,

    ApplyVehicleEffectList = function(vehicle, effects, state, is_a_player, god_finger)
        if state[vehicle] == nil then state[vehicle] = {} end
        local parsed = Ryan.UI.ParseEffectList(effects, god_finger)

        if parsed.speed and parsed.speed.fast and (not is_a_player or state[vehicle].speed ~= "fast") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Fast)
                state[vehicle].speed = "fast"
            end, is_a_player)
        elseif parsed.speed and parsed.speed.slow and (not is_a_player or state[vehicle].speed ~= "slow") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Slow)
                state[vehicle].speed = "slow"
            end, is_a_player)
        elseif parsed.speed and parsed.speed.normal and (not is_a_player or state[vehicle].speed ~= "normal") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Normal)
                state[vehicle].speed = "normal"
            end, is_a_player)
        end

        if parsed.grip and parsed.grip.none and (not is_a_player or state[vehicle].grip ~= "none") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetNoGrip(vehicle, true)
                state[vehicle].grip = "none"
            end, is_a_player)
        elseif parsed.grip and parsed.grip.normal and (not is_a_player or state[vehicle].grip ~= "normal") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetNoGrip(vehicle, false)
                state[vehicle].grip = "normal"
            end, is_a_player)
        end

        if parsed.doors and parsed.doors.lock and (not is_a_player or state[vehicle].doors ~= "lock") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetDoorsLocked(vehicle, true)
                state[vehicle].doors = "lock"
            end, is_a_player)
        elseif parsed.doors and parsed.doors.unlock and (not is_a_player or state[vehicle].doors ~= "unlock") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetDoorsLocked(vehicle, false)
                state[vehicle].doors = "unlock"
            end, is_a_player)
        end

        if parsed.tires and parsed.tires.burst and (not is_a_player or state[vehicle].tires ~= "burst") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetTiresBursted(vehicle, true)
                state[vehicle].tires = "burst"
            end, is_a_player)
        elseif parsed.tires and parsed.tires.fix and (not is_a_player or state[vehicle].tires ~= "fix") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetTiresBursted(vehicle, false)
                state[vehicle].tires = "fix"
            end, is_a_player)
        end

        if parsed.engine and parsed.engine.kill and (not is_a_player or state[vehicle].engine ~= "kill") then
            Ryan.Vehicle.Modify(vehicle, function()
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                state[vehicle].engine = "kill"
            end, is_a_player)
        elseif parsed.engine and parsed.engine.fix and (not is_a_player or state[vehicle].engine ~= "fix") then
            Ryan.Vehicle.Modify(vehicle, function()
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                state[vehicle].engine = "fix"
            end, is_a_player)
        end

        if enable_risky then
            if parsed.upgrades and parsed.upgrades.all and (not is_a_player or state[vehicle].upgrades ~= "all") then
                Ryan.Vehicle.Modify(vehicle, function()
                    Ryan.Vehicle.SetFullyUpgraded(vehicle, true)
                    state[vehicle].upgrades = "all"
                end, is_a_player)
            elseif parsed.upgrades and parsed.upgrades.none and (not is_a_player or state[vehicle].upgrades ~= "none") then
                Ryan.Vehicle.Modify(vehicle, function()
                    Ryan.Vehicle.SetFullyUpgraded(vehicle, false)
                    state[vehicle].upgrades = "none"
                end, is_a_player)
            end
        end

        if parsed.godmode and parsed.godmode.on and (not is_a_player or state[vehicle].godmode ~= "on") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_PROOFS(vehicle, true, true, true, true, true, 0, 0, true)
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, false)
                VEHICLE.SET_VEHICLE_FIXED(vehicle)
                state[vehicle].godmode = "on"
            end, is_a_player)
        elseif parsed.godmode and parsed.godmode.off and (not is_a_player or state[vehicle].godmode ~= "off") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_PROOFS(vehicle, false, false, false, false, false, 0, 0, false)
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
                state[vehicle].godmode = "off"
            end, is_a_player)
        end

        if parsed.gravity and parsed.gravity.none and (not is_a_player or state[vehicle].gravity ~= "on") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_HAS_GRAVITY(vehicle, false)
                VEHICLE.SET_VEHICLE_GRAVITY(vehicle, false)
                state[vehicle].gravity = "none"
            end, is_a_player)
        elseif parsed.gravity and parsed.gravity.normal and (not is_a_player or state[vehicle].gravity ~= "off") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_HAS_GRAVITY(vehicle, true)
                VEHICLE.SET_VEHICLE_GRAVITY(vehicle, true)
                state[vehicle].gravity = "normal"
            end, is_a_player)
        end

        if parsed.theft_alarm then
            if not VEHICLE.IS_VEHICLE_ALARM_ACTIVATED(vehicle) then
                Ryan.Vehicle.Modify(vehicle, function()
                    VEHICLE.SET_VEHICLE_ALARM(vehicle, true)
                    VEHICLE.START_VEHICLE_ALARM(vehicle)
                end, is_a_player)
            end
        end

        if parsed.catapult then
            if not state[vehicle].catapult or VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) and util.current_time_millis() - state[vehicle].catapult > 250 then
                Ryan.Vehicle.Modify(vehicle, function()
                    Ryan.Vehicle.Catapult(vehicle)
                end, is_a_player)
                state[vehicle].catapult = util.current_time_millis()
            end
        end
        
        if parsed.delete then
            entities.delete_by_handle(vehicle)
        end
    end
}