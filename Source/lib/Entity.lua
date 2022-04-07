function entity_get_all_nearby(coords, range, mode)
    mode = mode or NearbyEntitiesModes.All
    
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped())
    local nearby_entities = {}

    if mode == NearbyEntitiesModes.Peds or mode == NearbyEntitiesModes.All then
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if ped ~= player_ped then
                local ped_coords = ENTITY.GET_ENTITY_COORDS(ped)
                if vector_distance(coords, ped_coords) <= range then
                    table.insert(nearby_entities, ped)
                end
            end
        end
    end

    if mode == NearbyEntitiesModes.Vehicles or mode == NearbyEntitiesModes.All then
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

function entity_request_control(entity) -- Credit: WiriScript
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
		local network_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
	end
	return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

function entity_request_control_loop(entity) -- Credit: WiriScript
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

function entity_face_entity(entity_1, entity_2) -- Credit: WiriScript
	local a = ENTITY.GET_ENTITY_COORDS(entity_1)
	local b = ENTITY.GET_ENTITY_COORDS(entity_2)
	local dx = b.x - a.x
	local dy = b.y - a.y
	local heading = MISC.GET_HEADING_FROM_VECTOR_2D(dx, dy)
	return ENTITY.SET_ENTITY_HEADING(entity_1, heading)
end