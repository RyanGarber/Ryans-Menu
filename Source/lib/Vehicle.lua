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

    Catapult = function()
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 9999, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
    end
}