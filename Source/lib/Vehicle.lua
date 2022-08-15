Ryan.Vehicle = {}

Ryan.Vehicle.Speed = {
    Normal = 0,
    Fast = 1,
    Slow = 2
}

Ryan.Vehicle.GetClosest = function(coords)
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
end

Ryan.Vehicle.SetFullyUpgraded = function(vehicle, fully_upgraded)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
    for i = 0, 50 do
        local mod = -1
        if fully_upgraded then mod = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i) - 1 end
        VEHICLE.SET_VEHICLE_MOD(vehicle, i, mod, fully_upgraded)
    end
end

Ryan.Vehicle.SetSpeed = function(vehicle, speed)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        if speed == Ryan.Vehicle.Speed.Normal then
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, -1.0)
            ENTITY.SET_ENTITY_MAX_SPEED(vehicle, 64)
        else
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, if speed == Ryan.Vehicle.Speed.Fast then 1000000 else 2)
            ENTITY.SET_ENTITY_MAX_SPEED(vehicle, if speed == Ryan.Vehicle.Speed.Fast then 64 else 1)
        end
    end
end

Ryan.Vehicle.SetNoGrip = function(vehicle, no_grip)
    VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, no_grip)
    if no_grip then 
        VEHICLE._SET_VEHICLE_REDUCE_TRACTION(vehicle, 0.0)
    end
end

Ryan.Vehicle.SetDoorsLocked = function(vehicle, doors_locked)
    VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, if doors_locked then 4 else 0)
end

Ryan.Vehicle.SetTiresBursted = function(vehicle, tires_bursted)
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
end

Ryan.Vehicle.Catapult = function(vehicle)
    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 9999, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
end

Ryan.Vehicle.Steal = function(vehicle)
    if vehicle ~= 0 then
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        local failed_to_kick = false
        local start_time = util.current_time_millis()

        local driver_player_id = nil
        if driver ~= 0 and PED.IS_PED_A_PLAYER(driver) then
            for _, player_id in pairs(players.list()) do
                if Ryan.Player.Get(player_id).ped_id == driver then
                    driver_player_id = player_id
                end
            end
        end

        if driver_player_id ~= nil then
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Steal Vehicle", "Stealing the vehicle...")
            menu.trigger_commands("vehkick" .. players.get_name(driver_player_id))
        elseif driver ~= 0 then
            entities.delete_by_handle(driver)
        end
        
        while driver ~= 0 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) == driver do
            if util.current_time_millis() - start_time > 10000 then
                Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Steal Vehicle", "Failed to kick the driver of the vehicle.")
                failed_to_kick = true
                break
            end
            util.yield()
        end
        if not failed_to_kick then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
        end
    end
end

Ryan.Vehicle.MakeBlind = function(vehicle)
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
    local coords = ENTITY.GET_ENTITY_COORDS(vehicle)
    coords:add(math.random(-500, 500), math.random(-500, 500), 0)
    PED.SET_DRIVER_AGGRESSIVENESS(driver, 1.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(driver, vehicle, coords.x, coords.y, coords.z, 150.0, 524800, 20.0)

    --TASK.TASK_VEHICLE_DRIVE_WANDER(driver, vehicle, 10.0, 4719104)
    --MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, coords.z, ground_z, false)
end

Ryan.Vehicle.Modify = function(vehicle, action, take_control_loop)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then return end
    Ryan.Entity.RequestControl(vehicle, take_control_loop)
    action(vehicle)
end