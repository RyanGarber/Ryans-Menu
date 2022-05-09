Ryan.Entity = {
    Type = {
        All,
        Ped,
        Vehicle
    },

    GetAllNearby = function(coords, range, types)
        types = types or Ryan.Entity.Type.All
    
        local player_ped = Ryan.Player.GetPed()
        local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)
        local nearby_entities = {}
    
        if types == Ryan.Entity.Type.Peds or types == Ryan.Entity.Type.All then
            for _, ped in pairs(entities.get_all_peds_as_handles()) do
                if ped ~= player_ped then
                    local ped_coords = ENTITY.GET_ENTITY_COORDS(ped)
                    if Ryan.Vector.Distance(coords, ped_coords) <= range then
                        table.insert(nearby_entities, ped)
                    end
                end
            end
        end
    
        if types == Ryan.Entity.Type.Vehicles or types == Ryan.Entity.Type.All then
            for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
                if vehicle ~= player_vehicle then
                    local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
                    if Ryan.Vector.Distance(coords, vehicle_coords) <= range then
                        table.insert(nearby_entities, vehicle)
                    end
                end
            end
        end
    
        return nearby_entities
    end,

    RequestControl = function(entity)
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
            local network_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        end
        return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
    end,

    RequestControlLoop = function(entity)
        local tick = 0
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and tick < 25 do
            util.yield()
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
            tick = tick + 1
        end
        if NETWORK.NETWORK_IS_SESSION_STARTED() then
            local network_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
        end
    end,

    FaceEntity = function(entity_1, entity_2, use_pitch)
        local coords_1 = ENTITY.GET_ENTITY_COORDS(ent1, false)
        local coords_2 = ENTITY.GET_ENTITY_COORDS(ent2, false)
        local difference = Ryan.Vector.Subtract(coords_2, coords_1)
        local rotation = Ryan.Vector.DirectionToRotation(difference)
        if not use_pitch then
            ENTITY.SET_ENTITY_HEADING(entity_1, rotation.z)
        else
            ENTITY.SET_ENTITY_ROTATION(entity_1, rotation.x, rotation.y, rotation.z)
        end
    end,

    GetOffsetAtDistance = function(entity, distance)
        local coords = ENTITY.GET_ENTITY_COORDS(entity, 0)
        local theta = (math.random() + math.random(0, 1)) * math.pi
        return {
            x = coords.x + distance * math.cos(theta),
            y = coords.y + distance * math.sin(theta),
            z = coords.z
        }
    end,

    DrawESP = function(entity, esp_color)
        local color = {r = math.floor(esp_color.r * 255), g = math.floor(esp_color.g * 255), b = math.floor(esp_color.b * 255)}
        local minimum = v3.new()
        local maximum = v3.new()
        if ENTITY.DOES_ENTITY_EXIST(entity) then
            MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(entity), minimum, maximum)
            local width  = 2 * v3.getX(maximum)
            local length = 2 * v3.getY(maximum)
            local depth  = 2 * v3.getZ(maximum)
    
            local offset1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2,  depth / 2)
            local offset4 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2,  depth / 2)
            local offset5 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2, -depth / 2)
            local offset7 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2, -depth / 2)
            local offset2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2,  depth / 2) 
            local offset3 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2,  depth / 2)
            local offset6 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2, -depth / 2)
            local offset8 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2, -depth / 2)
    
            GRAPHICS.DRAW_LINE(offset1.x, offset1.y, offset1.z, offset4.x, offset4.y, offset4.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset1.x, offset1.y, offset1.z, offset2.x, offset2.y, offset2.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset1.x, offset1.y, offset1.z, offset5.x, offset5.y, offset5.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset2.x, offset2.y, offset2.z, offset3.x, offset3.y, offset3.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset3.x, offset3.y, offset3.z, offset8.x, offset8.y, offset8.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset4.x, offset4.y, offset4.z, offset7.x, offset7.y, offset7.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset4.x, offset4.y, offset4.z, offset3.x, offset3.y, offset3.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset5.x, offset5.y, offset5.z, offset7.x, offset7.y, offset7.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset6.x, offset6.y, offset6.z, offset2.x, offset2.y, offset2.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset6.x, offset6.y, offset6.z, offset8.x, offset8.y, offset8.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset5.x, offset5.y, offset5.z, offset6.x, offset6.y, offset6.z, color.r, color.g, color.b, 255)
            GRAPHICS.DRAW_LINE(offset7.x, offset7.y, offset7.z, offset8.x, offset8.y, offset8.z, color.r, color.g, color.b, 255)
        end
        v3.free(minimum)
        v3.free(maximum)
    end,

    Spotlights = {},

    AddSpotlight = function(entity, offset, intensity)
        if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            if VEHICLE.IS_VEHICLE_MODEL(entity, 1518533038) or VEHICLE.IS_VEHICLE_MODEL(387748548) then
                local trailer_ptr = memory.alloc_int()
                VEHICLE.GET_VEHICLE_TRAILER_VEHICLE(entity, trailer_ptr)
                local trailer = memory.read_int(trailer_ptr); memory.free(trailer_ptr)
                if trailer ~= 0 then
                    Ryan.Entity.AddSpotlight(trailer, offset, intensity)
                    return
                end
            end
        end

        local coords = ENTITY.GET_ENTITY_COORDS(entity)
        local model = ENTITY.GET_ENTITY_MODEL(entity)

        local minimum_ptr, maximum_ptr = memory.alloc(), memory.alloc()
        MISC.GET_MODEL_DIMENSIONS(model, minimum_ptr, maximum_ptr)
        local minimum = memory.read_vector3(minimum_ptr); memory.free(minimum_ptr)
        local maximum = memory.read_vector3(maximum_ptr); memory.free(maximum_ptr)

        local wall_light = util.joaat("prop_wall_light_15a")

        if Ryan.Entity.Spotlights[entity] == nil then
            for i = 1, intensity do
                Ryan.Entity.Spotlights[entity] = true

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
    end
}