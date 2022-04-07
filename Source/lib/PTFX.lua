function ptfx_request_asset(ptfx)
    STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx)
	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(ptfx) do
		util.yield()
	end
end

function ptfx_create_list(root, loop)
    for name, ptfx in pairs(PTFX) do
        menu.toggle_loop(root, name, {"ryan" .. name:lower()}, "Plays the " .. name .. " effect.", function()
            loop(ptfx)
        end, false)
    end
end

function ptfx_play_at_coords(coords, ptfx_group, ptfx_name, color)
    ptfx_request_asset(ptfx_group)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
    if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
        ptfx_name, coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0, 1.0, 
		false, false, false
	)
end

function ptfx_play_on_entity(entity, ptfx_group, ptfx_name, color)
    ptfx_request_asset(ptfx_group)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
    if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(
        ptfx_name, entity, 
		0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 
		false, false, false
	)
end

function ptfx_play_on_entity_bones(entity, bones, ptfx_group, ptfx_name, color)
    ptfx_request_asset(ptfx_group)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
    for _, bone in pairs(bones) do
        local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, bone)
        local coords = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, bone_index)
        if vector_magnitude(coords) > 0.0 then
            GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
            if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
            GRAPHICS._START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                ptfx_name, entity,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, bone),
                1.0,
                false, false, false
            )
        end
    end
end

function ptfx_play_at_entity_bone_coords(entity, bones, ptfx_group, name, color)
    for _, bone in pairs(bones) do
        local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, bone)
        local coords = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, bone_index)
        if vector_magnitude(coords) > 0.0 then
            ptfx_play_at_coords(coords, ptfx_group, name, color)
        end
    end
end