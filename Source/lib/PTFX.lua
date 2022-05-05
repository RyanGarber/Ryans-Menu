Ryan.PTFX = {
    PlayerBones = {
        Head = {"IK_Head"},
        Hands = {"IK_L_Hand", "IK_R_Hand"},
        Pointer = {"IK_L_Hand"},
        Feet = {"IK_L_Foot", "IK_R_Foot"}
    },
    
    VehicleBones = {
        Wheels = {"wheel_lf", "wheel_lr", "wheel_rf", "wheel_rr"},
        Exhaust = {"exhaust", "exhaust_2", "exhaust_3", "exhaust_4", "exhaust_5", "exhaust_6", "exhaust_7", "exhaust_8"}
    },
    
    WeaponBones = {
        Muzzle = {"gun_vfx_eject"}
    },

    Request = function(asset)
        STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
            util.yield()
        end
    end,

    CreateList = function(root, loop)
        for _, ptfx in pairs(Ryan.Globals.PTFX) do
            menu.toggle_loop(root, ptfx[1], {"ryan" .. ptfx[1]:lower()}, "Plays the " .. ptfx[1] .. " effect.", function()
                loop(ptfx)
            end)
        end
    end,

    PlayAtCoords = function(coords, ptfx_group, ptfx_name, color)
        Ryan.PTFX.Request(ptfx_group)
        GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
        if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
            ptfx_name, coords.x, coords.y, coords.z,
            0.0, 0.0, 0.0, 1.0, 
            false, false, false
        )
    end,

    PlayOnEntity = function(entity, ptfx_group, ptfx_name, color)
        Ryan.PTFX.Request(ptfx_group)
        GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
        if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(
            ptfx_name, entity, 
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 
            false, false, false
        )
    end,

    PlayOnEntityBones = function(entity, bones, ptfx_group, ptfx_name, color)
        Ryan.PTFX.Request(ptfx_group)
        GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
        for _, bone in pairs(bones) do
            local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, bone)
            local coords = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, bone_index)
            if Ryan.Vector.Magnitude(coords) > 0.0 then
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
    end,

    PlayAtEntityBoneCoords = function(entity, bones, ptfx_group, name, color)
        for _, bone in pairs(bones) do
            local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, bone)
            local coords = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, bone_index)
            if Ryan.Vector.Magnitude(coords) > 0.0 then
                Ryan.PTFX.PlayAtCoords(coords, ptfx_group, name, color)
            end
        end
    end
}