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
            if maxed then
                mod = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i) - 1
            end
            VEHICLE.SET_VEHICLE_MOD(vehicle, i, mod, maxed)
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
}