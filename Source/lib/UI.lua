UI = {}

-- General UI --
UI.CreateList = function(root, menu_name, command_name, description, choices, on_update)
    on_update(choices[1])
    return menu.list_select(root, menu_name, {command_name}, description, choices, 1, function(value)
        on_update(choices[value])
    end)
end

UI.CreateEffectChoice = function(root, command_prefix, player_name, effects, effect_name, effect_description, options, god_finger)
    local command = command_prefix .. Ryan.CommandName(effect_name)

    if god_finger then
        local effect_root = menu.list(root, effect_name, {command}, effect_description)
        for _, choice in pairs(options) do
            if effects[Ryan.ToTableName(effect_name)] == nil then effects[Ryan.ToTableName(effect_name)] = {} end

            UI.CreateList(effect_root, choice, command .. Ryan.CommandName(choice), "", UI.GodFingerActivationModes, function(value)
                effects[Ryan.ToTableName(effect_name)][Ryan.ToTableName(choice)] = value
            end)
        end
    else
        local effect_root = menu.list(root, effect_name .. ": -", {command}, effect_description)
        for _, choice in pairs(options) do
            menu.toggle(effect_root, choice, {command .. Ryan.CommandName(choice)}, "", function(value)
                if value then
                    for _, other_choice in pairs(options) do
                        if other_choice ~= choice then
                            menu.trigger_commands(command .. Ryan.CommandName(other_choice) .. player_name .. " off")
                        end
                    end
                    util.yield(500)
                    effects[Ryan.ToTableName(effect_name)] = Ryan.ToTableName(choice)
                    menu.set_menu_name(effect_root, effect_name .. ": " .. choice)
                else
                    effects[Ryan.ToTableName(effect_name)] = nil
                    menu.set_menu_name(effect_root, effect_name .. ": -")
                end
            end)
        end
    end
end

UI.CreateEffectToggle = function(root, command_prefix, effects, effect_name, effect_description, god_finger)
    if god_finger then
        UI.CreateList(root, effect_name, command_prefix .. Ryan.CommandName(effect_name), effect_description, UI.GodFingerActivationModes, function(value)
            effects[Ryan.ToTableName(effect_name)] = value
        end)
    else
        menu.toggle(root, effect_name, {command_prefix .. Ryan.CommandName(effect_name)}, effect_description, function(value)
            effects[Ryan.ToTableName(effect_name)] = value
        end)
    end
end

UI.CreateTeleportList = function(root, name, coords)
    for i = 1, #coords do
        local draw_beacon = false
        local teleport = menu.action(root, name .. " " .. i, {"ryan" .. Ryan.CommandName(name) .. i}, "Teleport to " .. name .. " #" .. i .. ".", function()
            Ryan.Teleport({x = coords[i][1], y = coords[i][2], z = coords[i][3]}, false)
        end)
        menu.on_focus(teleport, function() draw_beacon = true end)
        menu.on_blur(teleport, function() draw_beacon = false end)
        util.create_tick_handler(function()
            if draw_beacon then Ryan.DrawBeacon({x = coords[i][1], y = coords[i][2], z = coords[i][3]}) end
        end)
    end
end


-- God Finger UI --
UI.GodFingerActivationModes = {
    "Off",
    "Look",
    "Hold Q",
    "Hold E",
    "Hold R",
    "Hold F",
    "Hold C",
    "Hold X",
    "Hold Z",
    "Hold 1",
    "Hold 2",
    "Hold 3",
    "Hold 4",
    "Hold 5",
}

UI.GetGodFingerActivation = function(key)
    local activated = false
    pluto_switch key do
        case "Off":    activated = 0                                                                      break
        case "Look":   activated = 1                                                                      break
        case "Hold Q": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.Cover);               break
        case "Hold E": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.VehicleHorn);         break
        case "Hold R": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.Reload);              break
        case "Hold F": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.Enter);               break
        case "Hold C": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.LookBehind);          break
        case "Hold X": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.VehicleDuck);         break
        case "Hold Z": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.HudSpecial);          break
        case "Hold 1": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.SelectWeaponUnarmed); break
        case "Hold 2": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.SelectWeaponMelee);   break
        case "Hold 3": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.SelectWeaponShotgun); break
        case "Hold 4": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.SelectWeaponHeavy);   break
        case "Hold 5": activated = PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.SelectWeaponSpecial); break
    end
    pluto_switch activated do
        case true: return 2
        case false: return 0
        pluto_default: return activated
    end
end

UI.DisplayGodFingerKeybind = function(mode)
    if Ryan.TextKeybinds then return "<b>" .. mode:sub(6) .. "</b>]" end

    pluto_switch mode do
        case "Hold Q": return "~INPUT_COVER~"
        case "Hold E": return "~INPUT_VEH_HORN~"
        case "Hold R": return "~INPUT_RELOAD~"
        case "Hold F": return "~INPUT_ENTER~"
        case "Hold C": return "~INPUT_LOOK_BEHIND~"
        case "Hold X": return "~INPUT_VEH_DUCK~"
        case "Hold Z": return "~INPUT_HUD_SPECIAL~"
        case "Hold 1": return "~INPUT_SELECT_WEAPON_UNARMED~"
        case "Hold 2": return "~INPUT_SELECT_WEAPON_MELEE~"
        case "Hold 3": return "~INPUT_SELECT_WEAPON_SHOTGUN~"
        case "Hold 4": return "~INPUT_SELECT_WEAPON_HEAVY~"
        case "Hold 5": return "~INPUT_SELECT_WEAPON_SPECIAL~"
        pluto_default: return "<b>" .. mode:sub(6) .. "</b>]"
    end
end

UI.GetGodFingerKeybinds = function(effects)
    function split(help, new_help)
        local help_line = help:sub(1 - (help:reverse():find("\n") or 0))
        local help_line_length = help_line:gsub("~[A-Z_]+~", ""):gsub("<b>[^<]+</b>.", ""):gsub("   ", ""):len()
        local new_help_length = new_help:gsub("~[A-Z_]+~", ""):gsub("<b>[^<]+</b>.", ""):gsub("   ", ""):len()
        if help_line_length + new_help_length >= 28 then return "\n" .. new_help
        else return (if help_line_length > 0 then "   " else "") .. new_help end
    end

    help = ""

    for effect, value in pairs(effects) do
        if type(value) == "table" then
            for choice, mode in pairs(value) do
                if mode:find("Hold") then
                    help = help .. split(help, UI.DisplayGodFingerKeybind(mode) .. " " .. Ryan.FromTableName(effect) .. ": " .. Ryan.FromTableName(choice))
                end
            end
        else
            if value:find("Hold") then
                help = help .. split(help, UI.DisplayGodFingerKeybind(value) .. " " .. Ryan.FromTableName(effect))
            end
        end
    end

    return help
end

UI.DisableGodFingerKeybinds = function()
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.CharacterWheel, true)         -- Alt

    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.Cover, true)                  -- Q
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.VehicleRadioWheel, true)      -- Q
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.VehicleHorn, true)            -- E
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.Reload, true)                 -- R
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.MeleeAttackLight, true)       -- R
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.VehicleCinematicCamera, true) -- R
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.Enter, true)                  -- F
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.VehicleExit, true)            -- F
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.LookBehind, true)             -- C
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.VehicleLookBehind, true)      -- C
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.VehicleDuck, true)            -- X
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.MultiplayerInfo, true)        -- Z
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.HudSpecial, true)             -- Z
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.SelectWeaponUnarmed, true)    -- 1
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.SelectWeaponMelee, true)      -- 2
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.SelectWeaponShotgun, true)    -- 3
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.SelectWeaponHeavy, true)      -- 4
    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Controls.SelectWeaponSpecial, true)    -- 5
end

UI.ParseEffectList = function(effects, god_finger)
    local parsed = {}
    for effect, value in pairs(effects) do
        if god_finger then
            if type(value) == "table" then
                if parsed[effect] == nil then parsed[effect] = {} end
                for choice, mode in pairs(value) do
                    parsed[effect][choice] = UI.GetGodFingerActivation(mode) > 0
                end
            else
                parsed[effect] = UI.GetGodFingerActivation(value) > 0
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
end


-- NPC Effects UI --
UI.CreateNPCEffectList = function(root, command_prefix, effects, god_finger)
    UI.CreateEffectChoice(root, command_prefix, "", effects, "Scenario", "Change the NPC's current scenario.", {"Musician", "Janitor", "Paparazzi", "Human Statue"}, god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Nude", "Make the NPC nude.", god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Flee", "Make the NPC flee you.", god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Ragdoll", "Make the NPC ragdoll.", god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Skydive", "Make the NPC skydive in place.", god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Delete", "Delete the NPC.", god_finger)
end

UI.ApplyNPCEffectList = function(npc, effects, state, god_finger)
    if state[npc] == nil then state[npc] = {} end
    local parsed = UI.ParseEffectList(effects, god_finger)

    if parsed.scenario and parsed.scenario.musician and state[npc].scenario ~= "musician" then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
        TASK.TASK_START_SCENARIO_IN_PLACE(npc, "WORLD_HUMAN_MUSICIAN", 0, false)
        state[npc].scenario = "musician"
        if god_finger then Ryan.PlaySelectSound() end
    end
    if parsed.scenario and parsed.scenario.janitor and state[npc].scenario ~= "janitor" then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
        TASK.TASK_START_SCENARIO_IN_PLACE(npc, "WORLD_HUMAN_JANITOR", 0, false)
        state[npc].scenario = "janitor"
        if god_finger then Ryan.PlaySelectSound() end
    end
    if parsed.scenario and parsed.scenario.paparazzi and state[npc].scenario ~= "paparazzi" then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
        TASK.TASK_START_SCENARIO_IN_PLACE(npc, "WORLD_HUMAN_PAPARAZZI", 0, false)
        state[npc].scenario = "paparazzi"
        if god_finger then Ryan.PlaySelectSound() end
    end
    if parsed.scenario and parsed.scenario.human_statue and state[npc].scenario ~= "human_statue" then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        TASK.TASK_START_SCENARIO_IN_PLACE(ped, "WORLD_HUMAN_HUMAN_STATUE", 0, false)
        state[npc].scenario = "human_statue"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.nude and not state[npc].nude then
        if god_finger or math.random(1, 25) == 1 then
            Ryan.RequestModel(util.joaat("a_f_y_topless_01"))

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
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.flee and not state[npc].flee then
        TASK.TASK_SMART_FLEE_PED(npc, players.user_ped(), 500.0, -1, false, false)
        PED.SET_PED_KEEP_TASK(npc, true)
        state[npc].flee = true
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.ragdoll then
        PED.SET_PED_TO_RAGDOLL(npc, 1000, 1000, 0, 0, 0, 0)
    end
    if god_finger then Ryan.ToggleSelectSound(parsed, state, "ragdoll") end

    if parsed.skydive and util.current_time_millis() - (state[npc].skydive or 0) >= 2500 then
        TASK.TASK_SKY_DIVE(npc, true)
        state[npc].skydive = util.current_time_millis()
    end
    if god_finger then Ryan.ToggleSelectSound(parsed, state, "skydive") end

    if parsed.delete then
        entities.delete_by_handle(npc)
        if god_finger then Ryan.PlaySelectSound() end
    end
end


-- Vehicle Effects UI --
UI.CreateVehicleEffectList = function(root, command_prefix, player_name, effects, enable_risky, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Speed", "Change the speed of the vehicle.", {"Fast", "Slow", "Normal"}, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Grip", "Change the grip of the vehicle's tires.", {"None", "Normal"}, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Door Locks", "Change the vehicle's door lock state.", {"Lock", "Unlock"}, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Parts", "Change the vehicle's parts visually.", {"Break", "Fix"}, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Tires", "Change the vehicle's tire health.", {"Burst", "Fix"}, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Engine", "Change the vehicle's engine health.", {"Kill", "Fix"}, god_finger)
    if enable_risky then
        UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Upgrades", "Change the vehicle's upgrades.", {"All", "None"}, god_finger)
    end
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Godmode", "Change the vehicle's upgrades.", {"On", "Off"}, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Gravity", "Change the vehicle's gravity.", {"None", "Normal"}, god_finger)
    UI.CreateEffectChoice(root, command_prefix, player_name, effects, "Visibility", "Change the vehicle's visibility.", {"Invisible", "Visible"}, god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Theft Alarm", "Trigger the vehicle's theft alarm.", god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Catapult", "Catapult the vehicle non-stop.", god_finger)
    UI.CreateEffectToggle(root, command_prefix, effects, "Delete", "Delete the vehicle.", god_finger)
end

UI.ApplyVehicleEffectList = function(vehicle, effects, state, is_a_player, god_finger)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then return end
    if state[vehicle] == nil then state[vehicle] = {} end
    local parsed = UI.ParseEffectList(effects, god_finger)

    if parsed.speed and parsed.speed.fast and state[vehicle].speed ~= "fast" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleSpeed(vehicle, Objects.VehicleSpeed.Fast)
        state[vehicle].speed = "fast"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.speed and parsed.speed.slow and state[vehicle].speed ~= "slow" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleSpeed(vehicle, Objects.VehicleSpeed.Slow)
        state[vehicle].speed = "slow"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.speed and parsed.speed.normal and state[vehicle].speed ~= "normal" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleSpeed(vehicle, Objects.VehicleSpeed.Normal)
        state[vehicle].speed = "normal"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.grip and parsed.grip.none and state[vehicle].grip ~= "none" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleHasGrip(vehicle, false)
        state[vehicle].grip = "none"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.grip and parsed.grip.normal and state[vehicle].grip ~= "normal" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleHasGrip(vehicle, true)
        state[vehicle].grip = "normal"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.parts and parsed.parts.break and state[vehicle].parts ~= "break" then
        Objects.RequestControl(vehicle, is_a_player)
        local door_count = VEHICLE._GET_NUMBER_OF_VEHICLE_DOORS(vehicle)
        for i = 0, door_count - 1 do
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
        end
        VEHICLE.POP_OUT_VEHICLE_WINDSCREEN(vehicle_id)
        state[vehicle].parts = "break"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.parts and parsed.parts.fix and state[vehicle].parts ~= "fix" then
        Objects.RequestControl(vehicle, is_a_player)
        VEHICLE.SET_VEHICLE_FIXED(vehicle)
        state[vehicle].parts = "fix"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.door_locks and parsed.door_locks.lock and state[vehicle].door_locks ~= "lock" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleDoorsLocked(vehicle, true)
        state[vehicle].door_locks = "lock"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.door_locks and parsed.door_locks.unlock and state[vehicle].door_locks ~= "unlock" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleDoorsLocked(vehicle, false)
        state[vehicle].door_locks = "unlock"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.tires and parsed.tires.burst and state[vehicle].tires ~= "burst" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleTiresBursted(vehicle, true)
        state[vehicle].tires = "burst"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.tires and parsed.tires.fix and state[vehicle].tires ~= "fix" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleTiresBursted(vehicle, false)
        state[vehicle].tires = "fix"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.engine and parsed.engine.kill and state[vehicle].engine ~= "kill" then
        Objects.RequestControl(vehicle, is_a_player)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
        state[vehicle].engine = "kill"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.engine and parsed.engine.fix and state[vehicle].engine ~= "fix" then
        Objects.RequestControl(vehicle, is_a_player)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
        state[vehicle].engine = "fix"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.upgrades and parsed.upgrades.all and state[vehicle].upgrades ~= "all" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleFullyUpgraded(vehicle, true)
        state[vehicle].upgrades = "all"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.upgrades and parsed.upgrades.none and state[vehicle].upgrades ~= "none" then
        Objects.RequestControl(vehicle, is_a_player)
        Objects.SetVehicleFullyUpgraded(vehicle, false)
        state[vehicle].upgrades = "none"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.godmode and parsed.godmode.on and state[vehicle].godmode ~= "on" then
        Objects.RequestControl(vehicle, is_a_player)
        ENTITY.SET_ENTITY_PROOFS(vehicle, true, true, true, true, true, 0, 0, true)
        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, false)
        VEHICLE.SET_VEHICLE_FIXED(vehicle)
        state[vehicle].godmode = "on"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.godmode and parsed.godmode.off and state[vehicle].godmode ~= "off" then
        Objects.RequestControl(vehicle, is_a_player)
        ENTITY.SET_ENTITY_PROOFS(vehicle, false, false, false, false, false, 0, 0, false)
        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
        state[vehicle].godmode = "off"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.gravity and parsed.gravity.none and state[vehicle].gravity ~= "none" then
        Objects.RequestControl(vehicle, is_a_player)
        ENTITY.SET_ENTITY_HAS_GRAVITY(vehicle, false)
        VEHICLE.SET_VEHICLE_GRAVITY(vehicle, false)
        state[vehicle].gravity = "none"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.gravity and parsed.gravity.normal and state[vehicle].gravity ~= "normal" then
        Objects.RequestControl(vehicle, is_a_player)
        ENTITY.SET_ENTITY_HAS_GRAVITY(vehicle, true)
        VEHICLE.SET_VEHICLE_GRAVITY(vehicle, true)
        state[vehicle].gravity = "normal"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.visibility and parsed.visibility.invisible and state[vehicle].visibility ~= "invisible" then
        Objects.RequestControl(vehicle, is_a_player)
        ENTITY.SET_ENTITY_VISIBLE(vehicle, false)
        ENTITY.SET_ENTITY_ALPHA(vehicle, 1)
        state[vehicle].visibility = "invisible"
        if god_finger then Ryan.PlaySelectSound() end
    elseif parsed.visibility and parsed.visibility.visible and state[vehicle].visibility ~= "visible" then
        Objects.RequestControl(vehicle, is_a_player)
        ENTITY.SET_ENTITY_VISIBLE(vehicle, true)
        ENTITY.SET_ENTITY_ALPHA(vehicle, 255)
        state[vehicle].visibility = "visible"
        if god_finger then Ryan.PlaySelectSound() end
    end

    if parsed.theft_alarm and not VEHICLE.IS_VEHICLE_ALARM_ACTIVATED(vehicle) then
        Objects.RequestControl(vehicle, is_a_player)
        VEHICLE.SET_VEHICLE_ALARM(vehicle, true)
        VEHICLE.START_VEHICLE_ALARM(vehicle)
    end
    if god_finger then Ryan.ToggleSelectSound(parsed, state, "theft_alarm") end

    if parsed.catapult then
        if not state[vehicle].catapult or VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) and util.current_time_millis() - state[vehicle].catapult >= 500 then
            Objects.RequestControl(vehicle, is_a_player)
            Objects.Catapult(vehicle)
            state[vehicle].catapult = util.current_time_millis()
            if god_finger then Ryan.PlaySelectSound() end
        end
    end
    
    if parsed.delete then
        entities.delete_by_handle(vehicle)
        if god_finger then Ryan.PlaySelectSound() end
    end
end


-- Stats UI --
_kd_root, _kills, _deaths = nil, nil, nil

function _get_kills()
    return Ryan.GetStatInt(Ryan.GetStatHash(Ryan.StatType.Global, "KILLS_PLAYERS"))
end

function _get_deaths()
    return Ryan.GetStatInt(Ryan.GetStatHash(Ryan.StatType.Global, "DEATHS_PLAYER"))
end

function _set_kills(kills)
    STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Global, "KILLS_PLAYERS"), kills, true)
    STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "KILLS_PLAYERS"), kills)
end

function _set_deaths(deaths)
    STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Global, "DEATHS_PLAYER"), deaths)
    STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "DEATHS_PLAYER"), deaths)
end

UI.UpdateKDMenu = function(root)
    if _kills ~= nil then menu.delete(_kills); _kills = nil end
    if _deaths ~= nil then menu.delete(_deaths); _deaths = nil end
    if _kd ~= nil then menu.delete(_kd); _kd = nil end

    _kills = menu.text_input(root, "Kills: -", {"ryankills"}, "The amount of kills you have given.", function(value)
        value = tonumber(value)
        if value ~= nil then
            _set_kills(math.floor(value))
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Stats", "Your kill count has been changed to " .. value .. "!")
        else
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Stats", "The kill count you provided was not a valid number.")
        end
        UI.UpdateKDMenu(root)
    end)

    _deaths = menu.text_input(root, "Deaths: -", {"ryandeaths"}, "The amount of deaths you have received.", function(value)
        value = tonumber(value)
        if value ~= nil then
            _set_deaths(math.floor(value))
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Stats", "Your death count has been changed to " .. value .. "!")
        else
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Stats", "The death count you provided was not a valid number.")
        end
        UI.UpdateKDMenu(root)
    end)

    _kd = menu.divider(root, "K/D: -")
end

util.create_tick_handler(function()
    if _kills ~= nil and _deaths ~= nil then
        local kills, deaths = _get_kills(), _get_deaths()
        menu.set_menu_name(_kills, "Kills: " .. kills)
        menu.set_menu_name(_deaths, "Deaths: " .. deaths)
        menu.set_menu_name(_kd, "K/D: " .. string.format("%.2f", kills / deaths))
        util.yield(1000)
    end
end)

UI.CreateOfficeMoneyButton = function(root, percentage, amount)
    menu.action(root, percentage .. "% Full", {"ryanofficemoney" .. percentage}, "Make the office " .. percentage .. "% full with money.", function(click_type)
        menu.show_warning(menu.ref_by_command_name("ryanofficemoney" .. percentage), click_type, "Make sure you have at least 1 crate of Special Cargo to sell before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell that cargo.", function()
            STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_CONTRA_EARNINGS"), amount, true)
            STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BUY_COMPLETE"), 1000, true)
            STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_SELL_COMPLETE"), 1000, true)
            STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BUY_UNDERTAKEN"), 1000, true)
            STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BUY_UNDERTAKEN"), 1000, true)
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "CEO Office Money", "Done! Switch sessions and start a Special Cargo sale to apply your changes.")
        end)
    end)
end

UI.CreateMCClutterButton = function(root, percentage, amount)
    local command = menu.action(root, percentage .. "% Full", {"ryanmcclutter" .. percentage}, "Add drugs, money, and other clutter to your M.C. clubhouse.", function(click_type)
        menu.show_warning(menu.ref_by_command_name("ryanmcclutter" .. percentage), click_type, "Make sure you have at least 1 unit of stock to sell, in every business, before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell all of those, one by one.", function()
            for i = 0, 5 do
                STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BKR_SELL_EARNINGS" .. i), amount, true)
                STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BIKER_BUY_COMPLET" .. (if i == 0 then "" else i)), 1000, true)
                STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BIKER_BUY_UNDERTA" .. (if i == 0 then "" else i)), 1000, true)
                STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BIKER_SELL_COMPLET" .. (if i == 0 then "" else i)), 1000, true)
                STATS.STAT_SET_INT(Ryan.GetStatHash(Ryan.StatType.Character, "LIFETIME_BIKER_SELL_UNDERTA" .. (if i == 0 then "" else i)), 1000, true)
            end
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "M.C. Clubhouse Clutter", "Done! Switch sessions and start a sale in every business to apply changes.")
        end)
    end)
end

local _dynamic_player_lists = {}
UI.CreateDynamicPlayerList = function(root, name, command, description, include, action, toggle)
    local do_update = false
    local list_root = menu.list(root, name, {command}, description, function()
        do_update = true
    end, function()
        do_update = false
    end)

    _dynamic_player_lists[list_root] = {include = include, action = action, divider = menu.divider(list_root, "Players")}
    util.create_tick_handler(function()
        if _dynamic_player_lists[list_root] == nil then return false end
        if not do_update then return end

        for player_id, action in pairs(_dynamic_player_lists[list_root]) do
            if player_id == "include" or player_id == "action" or player_id == "divider" then continue end
            if not Player:Exists(player_id) or not _dynamic_player_lists[list_root].include(Player:Get(player_id)) then
                menu.delete(action)
                _dynamic_player_lists[list_root][player_id] = nil
            end
        end
    
        for _, player_id in pairs(players.list()) do
            if _dynamic_player_lists[list_root][player_id] == nil and _dynamic_player_lists[list_root].include(Player:Get(player_id)) then
                local create = if toggle then menu.toggle else menu.action
                local tags = players.get_tags_string(player_id)
                local name = players.get_name(player_id) .. (if tags:len() > 0 then (" [" .. tags .. "]") else "")
                _dynamic_player_lists[list_root][player_id] = create(list_root, name, {}, "", function(value)
                    if toggle then
                        _dynamic_player_lists[list_root].action(Player:Get(player_id), value)
                    else
                        _dynamic_player_lists[list_root].action(Player:Get(player_id))
                    end
                end)
            end
        end
        util.yield(100)
    end)

    return root
end

UI.DeleteDynamicPlayerList = function(root)
    _dynamic_player_lists[root] = nil
end