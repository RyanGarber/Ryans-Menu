function entity_get_all_nearby(coords, range, mode)
    mode = mode or NearbyEntitiesModes.All
    
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped())
    local nearby_entities = {}

    if mode == NearbyEntities.Peds or mode == NearbyEntities.All then
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if ped ~= player_ped then
                local ped_coords = ENTITY.GET_ENTITY_COORDS(ped)
                if vector_distance(coords, ped_coords) <= range then
                    table.insert(nearby_entities, ped)
                end
            end
        end
    end

    if mode == NearbyEntities.Vehicles or mode == NearbyEntities.All then
        for _, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
            if vehicle ~= player_vehicle then
                local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
                if vector_distance(coords, vehicle_coords) <= range then
                    table.insert(nearby_entities, vehicle)
                end
            end
        end
    end

    return nearby_entities
end

function entity_request_control(entity, reason) -- Credit: WiriScript
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
		local network_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
	end
	return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

function entity_request_control_loop(entity, reason) -- Credit: WiriScript
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
end

function entity_face_entity(entity_1, entity_2, use_pitch)
    local coords_1 = ENTITY.GET_ENTITY_COORDS(ent1, false)
	local coords_2 = ENTITY.GET_ENTITY_COORDS(ent2, false)
	local difference = vector_subtract(coords_2, coords_1)
	local rotation = vector_direction_to_rotation(difference)
	if not use_pitch then
		ENTITY.SET_ENTITY_HEADING(entity_1, rotation.z)
	else
		ENTITY.SET_ENTITY_ROTATION(entity_1, rotation.x, rotation.y, rotation.z)
	end
end

function entity_get_offset_at_distance(entity, distance) -- Credit: WiriScript
    local coords = ENTITY.GET_ENTITY_COORDS(entity, 0)
	local theta = (math.random() + math.random(0, 1)) * math.pi --returns a random angle between 0 and 2pi (exclusive)
	return {
		x = coords.x + distance * math.cos(theta),
		y = coords.y + distance * math.sin(theta),
		z = coords.z
    }
end