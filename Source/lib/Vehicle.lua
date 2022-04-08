function vehicle_get_closest(coords) -- Credit: LanceScript
    local vehicles = entities.get_all_vehicles_as_handles()
    local closest_distance = 1000000
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

function vehicle_set_upgraded(vehicle, maxed)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
    for i=0, 50 do
        local mod = -1
        if maxed then
            mod = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i) - 1
        end
        VEHICLE.SET_VEHICLE_MOD(vehicle, i, mod, false)
    end
end

function vehicle_set_speed(vehicle, fast)
    entity_request_control_loop(vehicle)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        ENTITY.SET_ENTITY_MAX_SPEED(vehicle, fast and 64 or 1)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, fast and 1000000 or 2)
    end
end

function vehicle_set_no_grip(vehicle, no_grip)
    entity_request_control_loop(vehicle)
    VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, no_grip)
end

function vehicle_lock_doors(vehicle)
    entity_request_control_loop(vehicle)
    VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 4)
end

function vehicle_burst_tires(vehicle)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true)
    for tire = 0, 7 do
        VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, tire, true, 1000.0)
    end
end

function vehicle_catapult(vehicle)
    if VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) then
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 9999, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
    end
end