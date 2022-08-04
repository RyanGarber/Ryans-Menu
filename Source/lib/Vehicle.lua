Ryan.Vehicle = {
    Speed = {
        Normal = 0,
        Fast = 1,
        Slow = 2
    },

    GetClosest = function(coords)
        local vehicles = entities.get_all_vehicles_as_handles()
        local closest_distance = 2147483647
        local closest_vehicle = 0
        for _, vehicle in pairs(vehicles) do
            if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false) then
                local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
                local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(
                    coords.x, coords.y, coords.z,
                    vehicle_coords.x, vehicle_coords.y, vehicle_coords.z, true
                )
                if distance < closest_distance then
                    closest_distance = distance
                    closest_vehicle = vehicle
                end
            end
        end
        return closest_vehicle
    end,

    SetFullyUpgraded = function(vehicle, fully_upgraded)
        VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
        for i = 0, 50 do
            local mod = -1
            if fully_upgraded then
                mod = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i) - 1
            end
            VEHICLE.SET_VEHICLE_MOD(vehicle, i, mod, fully_upgraded)
        end
    end,

    SetSpeed = function(vehicle, speed)
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
            if speed == Ryan.Vehicle.Speed.Normal then
                VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, -1.0)
                ENTITY.SET_ENTITY_MAX_SPEED(vehicle, 64)
            else
                VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, speed == Ryan.Vehicle.Speed.Fast and 1000000 or 2)
                ENTITY.SET_ENTITY_MAX_SPEED(vehicle, speed == Ryan.Vehicle.Speed.Fast and 64 or 1)
            end
        end
    end,

    SetNoGrip = function(vehicle, no_grip)
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, no_grip)
        if no_grip then 
            VEHICLE._SET_VEHICLE_REDUCE_TRACTION(vehicle, 0.0)
        end
    end,

    SetDoorsLocked = function(vehicle, doors_locked)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, doors_locked and 4 or 0)
    end,

    SetTiresBursted = function(vehicle, tires_bursted)
        if tires_bursted then VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true) end
        for tire = 0, 7 do
            if tires_bursted then
                if not VEHICLE.IS_VEHICLE_TYRE_BURST(vehicle, tire, true) then
                    VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, tire, tires_bursted, 1000.0)
                end
            else
                VEHICLE.SET_VEHICLE_TYRE_FIXED(vehicle, tire)
            end
        end
    end,

    Catapult = function(vehicle)
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 9999, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
    end,

    Steal = function(vehicle)
        if vehicle ~= 0 then
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            local failed_to_kick = false
            local start_time = util.current_time_millis()

            local driver_player_id = nil
            if driver ~= 0 and PED.IS_PED_A_PLAYER(driver) then
                for _, player_id in pairs(players.list()) do
                    if Ryan.Player.GetPed(player_id) == driver then
                        driver_player_id = player_id
                    end
                end
            end

            if driver_player_id ~= nil then
                Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Steal Vehicle", "Stealing the vehicle...")
                menu.trigger_commands("vehkick" .. players.get_name(driver_player_id))
            elseif driver ~= 0 then
                entities.delete_by_handle(driver)
            end
            
            while driver ~= 0 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) == driver do
                if util.current_time_millis() - start_time > 10000 then
                    Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Steal Vehicle", "Failed to kick the driver of the vehicle.")
                    failed_to_kick = true
                    break
                end
                util.yield()
            end
            if not failed_to_kick then
                Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Steal Vehicle", "Teleporting into the vehicle.")
                PED.SET_PED_INTO_VEHICLE(Ryan.Player.GetPed(), vehicle, -1)
            end
        end
    end,

    MakeBlind = function(vehicle)
        local driver = PED.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)

        PED.SET_DRIVER_AGGRESSIVENESS(driver, 1.0)
        local coords = Ryan.Vector.Add(ENTITY.GET_ENTITY_COORDS(vehicle), {x = math.random(-500, 500), y = math.random(-500, 500), z = 0})
        TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(driver, vehicle, coords.x, coords.y, coords.z, 150.0, 524800, 20.0)

        --TASK.TASK_VEHICLE_DRIVE_WANDER(driver, vehicle, 10.0, 4719104)
        --MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, coords.z, ground_z, false)
    end,

    Modify = function(vehicle, action, take_control_loop)
        if take_control_loop then Ryan.Entity.RequestControlLoop(vehicle)
        else Ryan.Entity.RequestControl(vehicle) end
        
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then action(vehicle) end
    end,

    CreateEffectChoice = function(root, command_prefix, player_name, effects, effect_name, effect_description, options, multi)
        if multi then
            command_prefix = command_prefix .. Ryan.Basics.CommandName(effect_name)
            local effect_root = menu.list(root, effect_name .. "...", {command_prefix}, effect_description)
            for _, choice in pairs(options) do
                if effects[Ryan.Basics.TableName(effect_name)] == nil then effects[Ryan.Basics.TableName(effect_name)] = {} end

                Ryan.Basics.CreateSavableChoiceWithDefault(effect_root, choice .. ": %", command_prefix .. Ryan.Basics.TableName(choice), "", Ryan.Globals.ActivationModes, function(value)
                    effects[Ryan.Basics.TableName(effect_name)][Ryan.Basics.TableName(choice)] = value
                end)
            end
        else
            local effect_root = menu.list(root, effect_name .. ": -", {command_prefix}, effect_description)
            for _, choice in pairs(options) do
                menu.toggle(effect_root, choice, {command_prefix .. Ryan.Basics.CommandName(choice)}, "", function(value)
                    if value then
                        for _, other_choice in pairs(options) do
                            if other_choice ~= choice then
                                Ryan.Basics.RunCommands({command_prefix .. Ryan.Basics.CommandName(other_choice .. player_name) .. " off"})
                            end
                        end
                        util.yield(500)
                        effects[Ryan.Basics.TableName(effect_name)] = Ryan.Basics.TableName(choice)
                        menu.set_menu_name(effect_root, effect_name .. ": " .. choice)
                    else
                        effects[Ryan.Basics.TableName(effect_name)] = nil
                        menu.set_menu_name(effect_root, effect_name .. ": -")
                    end
                end)
            end
        end
    end,

    CreateEffectToggle = function(root, command_prefix, effects, effect_name, effect_description, multi)
        if multi then
            Ryan.Basics.CreateSavableChoiceWithDefault(root, effect_name .. ": %", command_prefix .. Ryan.Basics.TableName(effect_name), "", Ryan.Globals.ActivationModes, function(value)
                effects[Ryan.Basics.TableName(effect_name)] = value
            end)
        else
            menu.toggle(root, effect_name, {command_prefix .. Ryan.Basics.CommandName(effect_name)}, effect_description, function(value)
                effects[Ryan.Basics.TableName(effect_name)] = value
            end)
        end
    end,

    CreateEffectList = function(root, command_prefix, player_name, effects, enable_risky, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Speed", "Change the speed of the vehicle.", {"Fast", "Slow", "Normal"}, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Grip", "Change the grip of the vehicle's tires.", {"None", "Normal"}, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Doors", "Change the vehicle's door lock state.", {"Lock", "Unlock"}, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Tires", "Change the vehicle's tire health.", {"Burst", "Fix"}, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Engine", "Change the vehicle's engine health.", {"Kill", "Fix"}, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Upgrades", "Change the vehicle's upgrades.", {"All", "None"}, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Godmode", "Change the vehicle's upgrades.", {"On", "Off"}, multi)
        Ryan.Vehicle.CreateEffectChoice(root, command_prefix, player_name, effects, "Gravity", "Change the vehicle's gravity.", {"None", "Normal"}, multi)
        Ryan.Vehicle.CreateEffectToggle(root, command_prefix, effects, "Theft Alarm", "Triggers the vehicle's theft alarm.", multi)
        Ryan.Vehicle.CreateEffectToggle(root, command_prefix, effects, "Catapult", "Catapults the vehicle non-stop.", multi)
        Ryan.Vehicle.CreateEffectToggle(root, command_prefix, effects, "Delete", "Deletes their vehicle.", multi)
    end,

    ParseEffects = function(effects, multi)
        local parsed = {}
        for effect, value in pairs(effects) do
            if multi then
                if type(value) == "table" then
                    if parsed[effect] == nil then parsed[effect] = {} end
                    for choice, mode in pairs(value) do
                        parsed[effect][choice] = Ryan.Basics.IsGodFingerEffectActivated(mode)
                    end
                else
                    parsed[effect] = Ryan.Basics.IsGodFingerEffectActivated(value)
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

    ApplyEffects = function(vehicle, effects, state, is_a_player, multi)
        if state[vehicle] == nil then state[vehicle] = {} end
        local parsed = Ryan.Vehicle.ParseEffects(effects, multi)

        -- Speed
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

        -- Grip
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

        -- Doors
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

        -- Tires
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

        -- Engine
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
            -- Upgrades
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

        -- Godmode
        if parsed.godmode and parsed.godmode.on and (not is_a_player or state[vehicle].godmode ~= "on") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, false)
                state[vehicle].godmode = "on"
            end, is_a_player)
        elseif parsed.godmode and parsed.godmode.off and (not is_a_player or state[vehicle].godmode ~= "off") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
                state[vehicle].godmode = "off"
            end, is_a_player)
        end

        -- Gravity
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

        -- Catapult (TODO: cooldown)
        if parsed.catapult then
            if not state[vehicle].catapult or VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) and util.current_time_millis() - state[vehicle].catapult > 250 then
                Ryan.Vehicle.Modify(vehicle, function()
                    Ryan.Vehicle.Catapult(vehicle)
                end, is_a_player)
                state[vehicle].catapult = util.current_time_millis()
            end
        end

        -- Alarm
        if parsed.alarm then
            if not VEHICLE.IS_VEHICLE_ALARM_ACTIVATED(vehicle) then
                Ryan.Vehicle.Modify(vehicle, function()
                    VEHICLE.SET_VEHICLE_ALARM(vehicle, true)
                    VEHICLE.START_VEHICLE_ALARM(vehicle)
                end, is_a_player)
            end
        end

        -- Delete
        if parsed.delete then
            entities.delete_by_handle(vehicle)
        end
    end
}