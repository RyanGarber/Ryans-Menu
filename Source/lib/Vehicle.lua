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
        for i=0, 50 do
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

    Modify = function(vehicle, action, take_control_loop)
        if take_control_loop then Ryan.Entity.RequestControlLoop(vehicle)
        else Ryan.Entity.RequestControl(vehicle) end
        
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then action(vehicle) end
    end,
    
    CreateEffectTable = function(more_effects)
        effects = {
            ["speed"] = nil,
            ["grip"] = nil,
            ["doors"] = nil,
            ["tires"] = nil,
            ["engine"] = nil,
            ["upgrades"] = nil,
            ["godmode"] = nil,
            ["gravity"] = nil,
            ["catapult"] = nil,
            ["alarm"] = nil,
            ["delete"] = nil
        }
        for key, value in pairs(more_effects) do effects[key] = value end
        return effects
    end,

    CreateEffectList = function(root, command_prefix, player_name, effects)
        -- Speed
        local speed_root = menu.list(root, "Speed: -", {command_prefix .. "speed"}, "Changes the speed of the vehicle.")
        menu.toggle(speed_root, "Fast", {command_prefix .. "speedfast"}, "Makes the speed extremely fast.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "speednormal" .. player_name .. " off",
                    command_prefix .. "speedslow" .. player_name .. " off"
                })
                util.yield(250)
                effects.speed = "fast"
                menu.set_menu_name(speed_root, "Speed: Fast")
            else
                effects.speed = nil
                menu.set_menu_name(speed_root, "Speed: -")
            end
        end)
        menu.toggle(speed_root, "Slow", {command_prefix .. "speedslow"}, "Makes the speed extremely slow.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .."speedfast" .. player_name .. " off",
                    command_prefix .."speednormal" .. player_name .. " off"
                })
                util.yield(250)
                effects.speed = "slow"
                menu.set_menu_name(speed_root, "Speed: Slow")
            else
                effects.speed = nil
                menu.set_menu_name(speed_root, "Speed: -")
            end
        end)
        menu.toggle(speed_root, "Normal", {command_prefix .. "speednormal"}, "Makes the speed normal again.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "speedfast" .. player_name .. " off",
                    command_prefix .. "speedslow" .. player_name .. " off"
                })
                util.yield(250)
                effects.speed = "normal"
                menu.set_menu_name(speed_root, "Speed: Normal")
            else
                effects.speed = nil
                menu.set_menu_name(speed_root, "Speed: -")
            end
        end)

        -- Grip
        local grip_root = menu.list(root, "Grip: -", {command_prefix .. "grip"}, "Changes the grip of the vehicle's tires.")
        menu.toggle(grip_root, "None", {command_prefix .. "gripnone"}, "Makes the tires have no grip.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "gripnormal" .. player_name .. " off"
                })
                util.yield(250)
                effects.grip = "none"
                menu.set_menu_name(grip_root, "Grip: None")
            else
                effects.grip = nil
                menu.set_menu_name(grip_root, "Grip: -")
            end
        end)
        menu.toggle(grip_root, "Normal", {command_prefix .. "gripnormal"}, "Makes the grip normal again.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "gripnone" .. player_name .. " off"
                })
                util.yield(250)
                effects.grip = "normal"
                menu.set_menu_name(grip_root, "Grip: Normal")
            else
                effects.grip = nil
                menu.set_menu_name(grip_root, "Grip: -")
            end
        end)

        -- Doors
        local doors_root = menu.list(root, "Doors: -", {command_prefix .. "doors"}, "Changes the vehicle's door lock state.")
        menu.toggle(doors_root, "Lock", {command_prefix .. "doorslock"}, "Locks the vehicle's doors.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "doorsunlock" .. player_name .. " off"
                })
                util.yield(250)
                effects.doors = "lock"
                menu.set_menu_name(doors_root, "Doors: Lock")
            else
                effects.doors = nil
                menu.set_menu_name(doors_root, "Doors: -")
            end
        end)
        menu.toggle(doors_root, "Unlock", {command_prefix .. "doorsunlock"}, "Unlocks the vehicle's doors.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "doorslock" .. player_name .. " off"
                })
                util.yield(250)
                effects.doors = "unlock"
                menu.set_menu_name(doors_root, "Doors: Unlock")
            else
                effects.doors = nil
                menu.set_menu_name(doors_root, "Doors: -")
            end
        end)

        -- Tires
        local tires_root = menu.list(root, "Tires: -", {command_prefix .. "tires"}, "Changes the vehicle's tire health.")
        menu.toggle(tires_root, "Burst", {command_prefix .. "tiresburst"}, "Makes the vehicle's tires burst.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "tiresfix" .. player_name .. " off"
                })
                util.yield(250)
                effects.tires = "burst"
                menu.set_menu_name(tires_root, "Tires: Burst")
            else
                effects.tires = nil
                menu.set_menu_name(tires_root, "Tires: -")
            end
        end)
        menu.toggle(tires_root, "Fix", {command_prefix .. "tiresfix"}, "Fixes the vehicle's tires.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "tiresburst" .. player_name .. " off"
                })
                util.yield(250)
                effects.tires = "fix"
                menu.set_menu_name(tires_root, "Tires: Fix")
            else
                effects.tires = nil
                menu.set_menu_name(tires_root, "Tires: -")
            end
        end)

        -- Engine
        local engine_root = menu.list(root, "Engine: -", {command_prefix .. "engine"}, "Changes the vehicle's engine health.")
        menu.toggle(engine_root, "Kill", {command_prefix .. "enginekill"}, "Makes the vehicle's engine die.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "enginefix" .. player_name .. " off"
                })
                util.yield(250)
                effects.engine = "kill"
                menu.set_menu_name(engine_root, "Engine: Kill")
            else
                effects.engine = nil
                menu.set_menu_name(engine_root, "Engine: -")
            end
        end)
        menu.toggle(engine_root, "Fix", {command_prefix .. "enginefix"}, "Fixes the vehicle's engine.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "enginekill" .. player_name .. " off"
                })
                util.yield(250)
                effects.engine = "fix"
                menu.set_menu_name(engine_root, "Engine: Fix")
            else
                effects.engine = nil
                menu.set_menu_name(engine_root, "Engine: -")
            end
        end)

        -- Upgrades
        local upgrades_root = menu.list(root, "Upgrades: -", {command_prefix .. "upgrades"}, "Changes the vehicle's upgrades.")
        menu.toggle(upgrades_root, "All", {command_prefix .. "upgradesall"}, "Fully upgrades the vehicle.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "upgradesnone" .. player_name .. " off"
                })
                util.yield(250)
                effects.upgrades = "all"
                menu.set_menu_name(upgrades_root, "Upgrades: All")
            else
                effects.upgrades = nil
                menu.set_menu_name(upgrades_root, "Upgrades: -")
            end
        end)
        menu.toggle(upgrades_root, "None", {command_prefix .. "upgradesnone"}, "Fully downgrades the vehicle.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "upgradesall" .. player_name .. " off"
                })
                util.yield(250)
                effects.upgrades = "none"
                menu.set_menu_name(upgrades_root, "Upgrades: None")
            else
                effects.upgrades = nil
                menu.set_menu_name(upgrades_root, "Upgrades: -")
            end
        end)

        -- Godmode
        local godmode_root = menu.list(root, "Godmode: -", {command_prefix .. "godmode"}, "Changes the vehicle's godmode state.")
        menu.toggle(godmode_root, "On", {command_prefix .. "godmodeon"}, "Makes the vehicle indestructible.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "godmodeoff" .. player_name .. " off"
                })
                util.yield(250)
                effects.godmode = "on"
                menu.set_menu_name(godmode_root, "Godmode: On")
            else
                effects.godmode = nil
                menu.set_menu_name(godmode_root, "Godmode: -")
            end
        end)
        menu.toggle(godmode_root, "Off", {command_prefix .. "godmodeoff"}, "Makes the vehicle destructible.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "godmodeon" .. player_name .. " off"
                })
                util.yield(250)
                effects.godmode = "off"
                menu.set_menu_name(godmode_root, "Godmode: Off")
            else
                effects.godmode = nil
                menu.set_menu_name(godmode_root, "Godmode: -")
            end
        end)

        -- Gravity
        local gravity_root = menu.list(root, "Gravity: -", {command_prefix .. "gravity"}, "Changes the vehicle's gravity.")
        menu.toggle(gravity_root, "None", {command_prefix .. "gravitynone"}, "Disables gravity on the vehicle.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "gravitynormal" .. player_name .. " off"
                })
                util.yield(250)
                effects.gravity = "none"
                menu.set_menu_name(gravity_root, "Gravity: None")
            else
                effects.gravity = nil
                menu.set_menu_name(gravity_root, "Gravity: -")
            end
        end)
        menu.toggle(gravity_root, "Normal", {command_prefix .. "gravitynormal"}, "Enables gravity on the vehicle.", function(value)
            if value then
                Ryan.Basics.RunCommands({
                    command_prefix .. "gravitynone" .. player_name .. " off"
                })
                util.yield(250)
                effects.gravity = "normal"
                menu.set_menu_name(gravity_root, "Gravity: Normal")
            else
                effects.gravity = nil
                menu.set_menu_name(gravity_root, "Gravity: -")
            end
        end)

        -- Alarm
        menu.toggle(root, "Theft Alarm", {command_prefix .. "alarm"}, "Triggers the vehicle's theft alarm.", function(value)
            effects.alarm = value
        end)

        -- Catapult
        menu.toggle(root, "Catapult", {command_prefix .. "catapult"}, "Catapults the vehicle non-stop.", function(value)
            effects.catapult = value
        end)

        -- Delete
        menu.toggle(root, "Delete", {command_prefix .. "delete"}, "Deletes their vehicle.", function(value)
            effects.delete = value
        end)
    end,

    ApplyEffects = function(vehicle, effects, state, is_a_player)
        if state[vehicle] == nil then state[vehicle] = {} end

        -- Speed
        if effects.speed == "fast" and (not is_a_player or state[vehicle].speed ~= "fast") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Fast)
                state[vehicle].speed = "fast"
            end, is_a_player)
        elseif effects.speed == "slow" and (not is_a_player or state[vehicle].speed ~= "slow") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Slow)
                state[vehicle].speed = "slow"
            end, is_a_player)
        elseif effects.speed == "normal" and (not is_a_player or state[vehicle].speed ~= "normal") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Normal)
                state[vehicle].speed = "normal"
            end, is_a_player)
        end

        -- Grip
        if effects.grip == "none" and (not is_a_player or state[vehicle].grip ~= "none") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetNoGrip(vehicle, true)
                state[vehicle].grip = "none"
            end, is_a_player)
        elseif effects.grip == "normal" and (not is_a_player or state[vehicle].grip ~= "normal") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetNoGrip(vehicle, false)
                state[vehicle].grip = "normal"
            end, is_a_player)
        end

        -- Doors
        if effects.doors == "lock" and (not is_a_player or state[vehicle].doors ~= "lock") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetDoorsLocked(vehicle, true)
                state[vehicle].doors = "lock"
            end, is_a_player)
        elseif effects.doors == "unlock" and (not is_a_player or state[vehicle].doors ~= "unlock") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetDoorsLocked(vehicle, false)
                state[vehicle].doors = "unlock"
            end, is_a_player)
        end

        -- Tires
        if effects.tires == "burst" and (not is_a_player or state[vehicle].tires ~= "burst") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetTiresBursted(vehicle, true)
                state[vehicle].tires = "burst"
            end, is_a_player)
        elseif effects.tires == "fix" and (not is_a_player or state[vehicle].tires ~= "fix") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetTiresBursted(vehicle, false)
                state[vehicle].tires = "fix"
            end, is_a_player)
        end

        -- Engine
        if effects.engine == "kill" and (not is_a_player or state[vehicle].engine ~= "kill") then
            Ryan.Vehicle.Modify(vehicle, function()
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                state[vehicle].engine = "kill"
            end, is_a_player)
        elseif effects.engine == "fix" and (not is_a_player or state[vehicle].engine ~= "fix") then
            Ryan.Vehicle.Modify(vehicle, function()
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                state[vehicle].engine = "fix"
            end, is_a_player)
        end

        -- Upgrades
        if effects.upgrades == "all" and (not is_a_player or state[vehicle].upgrades ~= "all") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetFullyUpgraded(vehicle, true)
                state[vehicle].upgrades = "all"
            end, is_a_player)
        elseif effects.upgrades == "none" and (not is_a_player or state[vehicle].upgrades ~= "none") then
            Ryan.Vehicle.Modify(vehicle, function()
                Ryan.Vehicle.SetFullyUpgraded(vehicle, false)
                state[vehicle].upgrades = "none"
            end, is_a_player)
        end

        -- Godmode
        if effects.godmode == "on" and (not is_a_player or state[vehicle].godmode ~= "on") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, false)
                state[vehicle].godmode = "on"
            end, is_a_player)
        elseif effects.godmode == "off" and (not is_a_player or state[vehicle].godmode ~= "off") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
                state[vehicle].godmode = "off"
            end, is_a_player)
        end

        -- Gravity
        if effects.gravity == "none" and (not is_a_player or state[vehicle].gravity ~= "on") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_HAS_GRAVITY(vehicle, false)
                VEHICLE.SET_VEHICLE_GRAVITY(vehicle, false)
                state[vehicle].gravity = "none"
            end, is_a_player)
        elseif effects.gravity == "normal" and (not is_a_player or state[vehicle].gravity ~= "off") then
            Ryan.Vehicle.Modify(vehicle, function()
                ENTITY.SET_ENTITY_HAS_GRAVITY(vehicle, true)
                VEHICLE.SET_VEHICLE_GRAVITY(vehicle, true)
                state[vehicle].gravity = "normal"
            end, is_a_player)
        end

        -- Catapult (TODO: cooldown)
        if effects.catapult then
            if VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) then
                Ryan.Vehicle.Modify(vehicle, function()
                    Ryan.Vehicle.Catapult(vehicle)
                end, is_a_player)
            end
        end

        -- Alarm
        if effects.alarm then
            if not VEHICLE.IS_VEHICLE_ALARM_ACTIVATED(vehicle) then
                Ryan.Vehicle.Modify(vehicle, function()
                    VEHICLE.SET_VEHICLE_ALARM(vehicle, true)
                    VEHICLE.START_VEHICLE_ALARM(vehicle)
                end, is_a_player)
            end
        end

        -- Delete
        if effects.delete then
            entities.delete_by_handle(vehicle)
        end
    end
}