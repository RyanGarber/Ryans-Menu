Ryan.Entity = {}
_spotlights = {}

-- Entity types to include.
Ryan.Entity.Type = {All, Ped, Vehicle}

-- Get all entities of type in range of the specified coordinates.
Ryan.Entity.GetAllNearby = function(coords, range, types)
    types = types or Ryan.Entity.Type.All

    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped())
    local nearby_entities = {}

    if types == Ryan.Entity.Type.Peds or types == Ryan.Entity.Type.All then
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if ped ~= players.user_ped() then
                local ped_coords = ENTITY.GET_ENTITY_COORDS(ped)
                if Ryan.Vector.Distance(coords, ped_coords) <= range then
                    table.insert(nearby_entities, ped)
                end
            end
        end
    end

    if types == Ryan.Entity.Type.Vehicles or types == Ryan.Entity.Type.All then
        for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
            local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
            if Ryan.Vector.Distance(coords, vehicle_coords) <= range then
                table.insert(nearby_entities, vehicle)
            end
        end
    end

    return nearby_entities
end

-- Request control of an entity, optionally wait until it has been received.
Ryan.Entity.RequestControl = function(entity, loop)
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

-- Make an entity face another entity.
Ryan.Entity.FaceEntity = function(entity_1, entity_2, use_pitch)
    local coords_1 = ENTITY.GET_ENTITY_COORDS(ent1, false)
    local coords_2 = ENTITY.GET_ENTITY_COORDS(ent2, false)
    local difference = Ryan.Vector.Subtract(coords_2, coords_1)
    local rotation = Ryan.Vector.DirectionToRotation(difference)
    if not use_pitch then
        ENTITY.SET_ENTITY_HEADING(entity_1, rotation.z)
    else
        ENTITY.SET_ENTITY_ROTATION(entity_1, rotation.x, rotation.y, rotation.z)
    end
end

-- Draw an ESP box around an entity.
Ryan.Entity.DrawESP = function(entity)
    if Ryan.Globals.HUDUseBeacon then
        Ryan.Basics.DrawBeacon(ENTITY.GET_ENTITY_COORDS(entity))
        return
    end

    local color = {r = math.floor(Ryan.Globals.HUDColor.r * 255), g = math.floor(Ryan.Globals.HUDColor.g * 255), b = math.floor(Ryan.Globals.HUDColor.b * 255)}
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
Ryan.Entity.AddSpotlight = function(entity, offset, intensity)
    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        for i = 1, #Ryan.Globals.Haulers do
            if VEHICLE.IS_VEHICLE_MODEL(entity, Ryan.Globals.Haulers[i]) then
                local trailer_ptr = memory.alloc_int()
                VEHICLE.GET_VEHICLE_TRAILER_VEHICLE(entity, trailer_ptr)
                local trailer = memory.read_int(trailer_ptr)
                if trailer ~= 0 then
                    Ryan.Entity.AddSpotlight(trailer, offset, intensity)
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
        Ryan.Entity.DetachAll(entity)
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
            local light = entities.create_object(wall_light, {x = coords.x + offsets[i].x, y = coords.y + offsets[i].y, z = coords.z + offsets[i].z})
            local rotation = Ryan.Vector.DirectionToRotation(Ryan.Vector.Normalize(Ryan.Vector.Subtract(ENTITY.GET_ENTITY_COORDS(light), ENTITY.GET_ENTITY_COORDS(entity))))
            ENTITY.ATTACH_ENTITY_TO_ENTITY(light, entity, 0, offsets[i].x, offsets[i].y, offsets[i].z, rotation.x, rotation.y, rotation.z, false, false, false, false, 0, true)
        end
    end
end

-- Detach all other entities from an entity.
Ryan.Entity.DetachAll = function(entity)
    local objects = entities.get_all_objects_as_handles()
    for _, object in pairs(objects) do
        if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(object, entity) then
            Ryan.Entity.RequestControl(object, true)
            ENTITY.DETACH_ENTITY(object, false, false)
            util.yield()
            entities.delete_by_handle(object)
        end
    end
end