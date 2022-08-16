Objects = {}

-- Entity types to include.
Objects.Type = {
    All = 1,
    Ped = 2,
    Vehicle = 3
}

-- Get all entities of type in range of the specified coordinates.
Objects.GetAllNearby = function(coords, range, types)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped())
    local nearby_objects = {}

    if types == Objects.Type.Ped or types == Objects.Type.All then
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if ped ~= players.user_ped() then
                local ped_coords = ENTITY.GET_ENTITY_COORDS(ped)
                if coords:distance(ped_coords) <= range then
                    table.insert(nearby_objects, ped)
                end
            end
        end
    end

    if types == Objects.Type.Vehicle or types == Objects.Type.All then
        for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
            local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
            if coords:distance(vehicle_coords) <= range then
                table.insert(nearby_objects, vehicle)
            end
        end
    end

    return nearby_objects
end

-- Request control of an entity, optionally wait until it has been received.
Objects.RequestControl = function(entity, loop)
    local network_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    if loop then
        local tick = 0
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and tick < 25 do
            util.yield()
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
            tick = tick + 1
        end
        if NETWORK.NETWORK_IS_SESSION_STARTED() then
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        end
    else
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        end
    end
    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

-- Draw an ESP box around an entity.
Objects.DrawESP = function(entity)
    if Ryan.HUDUseBeacon then
        Ryan.DrawBeacon(ENTITY.GET_ENTITY_COORDS(entity))
        return
    end

    local color = {r = math.floor(Ryan.HUDColor.r * 255), g = math.floor(Ryan.HUDColor.g * 255), b = math.floor(Ryan.HUDColor.b * 255)}
    local minimum = v3.new()
    local maximum = v3.new()
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(entity), minimum, maximum)
        local width  = 2 * maximum.x
        local length = 2 * maximum.y
        local depth  = 2 * maximum.z

        local offsets = {
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2,  depth / 2),
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2,  depth / 2),
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2,  depth / 2),
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2,  depth / 2),
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2, -depth / 2),
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2, -depth / 2),
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2, -depth / 2),
            ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2, -depth / 2)
        }

        GRAPHICS.DRAW_LINE(offsets[1].x, offsets[1].y, offsets[1].z, offsets[4].x, offsets[4].y, offsets[4].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[1].x, offsets[1].y, offsets[1].z, offsets[2].x, offsets[2].y, offsets[2].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[1].x, offsets[1].y, offsets[1].z, offsets[5].x, offsets[5].y, offsets[5].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[2].x, offsets[2].y, offsets[2].z, offsets[3].x, offsets[3].y, offsets[3].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[3].x, offsets[3].y, offsets[3].z, offsets[8].x, offsets[8].y, offsets[8].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[4].x, offsets[4].y, offsets[4].z, offsets[7].x, offsets[7].y, offsets[7].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[4].x, offsets[4].y, offsets[4].z, offsets[3].x, offsets[3].y, offsets[3].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[5].x, offsets[5].y, offsets[5].z, offsets[7].x, offsets[7].y, offsets[7].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[6].x, offsets[6].y, offsets[6].z, offsets[2].x, offsets[2].y, offsets[2].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[6].x, offsets[6].y, offsets[6].z, offsets[8].x, offsets[8].y, offsets[8].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[5].x, offsets[5].y, offsets[5].z, offsets[6].x, offsets[6].y, offsets[6].z, color.r, color.g, color.b, 255)
        GRAPHICS.DRAW_LINE(offsets[7].x, offsets[7].y, offsets[7].z, offsets[8].x, offsets[8].y, offsets[8].z, color.r, color.g, color.b, 255)
    end
end

-- Add spotlights to an entity at the specific offset and intensity.
_spotlights = {}

Objects.AddSpotlight = function(entity, offset, intensity)
    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        for i = 1, #Ryan.Haulers do
            if VEHICLE.IS_VEHICLE_MODEL(entity, Ryan.Haulers[i]) then
                local trailer_ptr = memory.alloc_int()
                VEHICLE.GET_VEHICLE_TRAILER_VEHICLE(entity, trailer_ptr)
                local trailer = memory.read_int(trailer_ptr)
                if trailer ~= 0 then
                    Objects.AddSpotlight(trailer, offset, intensity)
                    return
                else
                    break
                end
            end
        end
    end

    local coords = ENTITY.GET_ENTITY_COORDS(entity)
    local model = ENTITY.GET_ENTITY_MODEL(entity)

    local minimum, maximum = v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(model, minimum, maximum)

    local wall_light = util.joaat("prop_wall_light_15a")
    if _spotlights[entity] ~= nil then
        Objects.DetachAll(entity)
    end

    for i = 1, intensity do
        _spotlights[entity] = true

        local offsets = {
            {x = 0.0, y = 0.0, z = (maximum.z * offset - 0.5)},
            {x = 0.0, y = 0.0, z = (-maximum.z * offset - 0.5)},
            {x = 0.0, y = (maximum.y * offset * 0.66), z = -0.5},
            {x = 0.0, y = (-maximum.y * offset * 0.66), z = -0.5},
            {x = (maximum.x * offset), y = 0.0, z = -0.5},
            {x = (-maximum.x * offset), y = 0.0, z = -0.5}
        }
        for i = 1, #offsets do
            local coords = v3(coords.x + offsets[i].x, coords.y + offsets[i].y, coords.z + offsets[i].z)
            local light = entities.create_object(wall_light, coords)
            local rotation = ENTITY.GET_ENTITY_COORDS(entity):lookAt(coords)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(light, entity, 0, offsets[i].x, offsets[i].y, offsets[i].z, rotation.x, rotation.y, rotation.z, false, false, false, false, 0, true)
        end
    end
end

-- Detach all other entities from an entity.
Objects.DetachAll = function(entity)
    local objects = entities.get_all_objects_as_handles()
    for _, object in pairs(objects) do
        if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(object, entity) then
            Objects.RequestControl(object, true)
            ENTITY.DETACH_ENTITY(object, false, false)
            util.yield()
            entities.delete_by_handle(object)
        end
    end
end

Vehicle = {}

Vehicle.Speed = {
    Normal = 0,
    Fast = 1,
    Slow = 2
}

Vehicle.GetClosest = function(coords)
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

Vehicle.SetFullyUpgraded = function(vehicle, fully_upgraded)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
    for i = 0, 50 do
        local mod = -1
        if fully_upgraded then mod = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i) - 1 end
        VEHICLE.SET_VEHICLE_MOD(vehicle, i, mod, fully_upgraded)
    end
end

Vehicle.SetSpeed = function(vehicle, speed)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        if speed == Vehicle.Speed.Normal then
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, -1.0)
            ENTITY.SET_ENTITY_MAX_SPEED(vehicle, 64)
        else
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, if speed == Vehicle.Speed.Fast then 1000000 else 2)
            ENTITY.SET_ENTITY_MAX_SPEED(vehicle, if speed == Vehicle.Speed.Fast then 64 else 1)
        end
    end
end

Vehicle.SetNoGrip = function(vehicle, no_grip)
    VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, no_grip)
    if no_grip then 
        VEHICLE._SET_VEHICLE_REDUCE_TRACTION(vehicle, 0.0)
    end
end

Vehicle.SetDoorsLocked = function(vehicle, doors_locked)
    VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, if doors_locked then 4 else 0)
end

Vehicle.SetTiresBursted = function(vehicle, tires_bursted)
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

Vehicle.Catapult = function(vehicle)
    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 9999, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
end

Vehicle.Steal = function(vehicle)
    if vehicle ~= 0 then
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        local failed_to_kick = false
        local start_time = util.current_time_millis()

        local driver_player_id = nil
        if driver ~= 0 and PED.IS_PED_A_PLAYER(driver) then
            for _, player_id in pairs(players.list()) do
                if Player:Get(player_id).ped_id == driver then
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

Vehicle.MakeBlind = function(vehicle)
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
    local coords = ENTITY.GET_ENTITY_COORDS(vehicle)
    coords:add(math.random(-500, 500), math.random(-500, 500), 0)
    PED.SET_DRIVER_AGGRESSIVENESS(driver, 1.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(driver, vehicle, coords.x, coords.y, coords.z, 150.0, 524800, 20.0)

    --TASK.TASK_VEHICLE_DRIVE_WANDER(driver, vehicle, 10.0, 4719104)
    --MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, coords.z, ground_z, false)
end

Vehicle.Modify = function(vehicle, action, take_control_loop)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then return end
    Objects.RequestControl(vehicle, take_control_loop)
    action(vehicle)
end