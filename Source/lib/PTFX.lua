PTFX = {}

PTFX.Types = {
    {"Trail (White)", "scr_rcbarry2", "scr_exp_clown_trails", 500},
    {"Trail (Color)", "scr_powerplay", "sp_powerplay_beast_appear_trails", 500},
    {"Electrical Fire (Silent)", "core", "ent_dst_elec_fire_sp", 200},
    {"Electrical Fire (Noisy)", "core", "ent_dst_elec_crackle", 500},
    {"Electrical Malfunction", "cut_exile1", "cs_ex1_elec_malfunction", 500},
    {"Chandelier", "cut_family4", "cs_fam4_shot_chandelier", 100},
    {"Firework Trail (Short)", "scr_rcpaparazzo1", "scr_mich4_firework_sparkle_spawn", 500},
    {"Firework Trail (Long)", "scr_indep_fireworks", "scr_indep_firework_sparkle_spawn", 500},
    {"Firework Burst", "scr_indep_fireworks", "scr_indep_firework_trailburst_spawn", 500},
    {"Firework Trailburst", "scr_rcpaparazzo1", "scr_mich4_firework_trailburst_spawn", 500},
    {"Firework Fountain", "scr_indep_fireworks", "scr_indep_firework_trail_spawn", 500},
    {"Beast Vanish", "scr_powerplay", "scr_powerplay_beast_vanish", 1000},
    {"Beast Appear", "scr_powerplay", "scr_powerplay_beast_appear", 1000},
    {"Alien Teleport", "scr_rcbarry1", "scr_alien_teleport", 750},
    {"Alien Disintegrate", "scr_rcbarry1", "scr_alien_disintegrate", 500},
    {"Take Zone", "scr_ie_tw", "scr_impexp_tw_take_zone", 500},
    {"Jackhammer (Quiet)", "core", "ent_dst_bread", 50},
    {"Jackhammer (Loud)", "core", "bul_paper", 50},
    {"Vehicle Backfire", "core", "veh_backfire", 250},
    {"Tire Flash", "scr_carsteal4", "scr_carsteal5_car_muzzle_flash", 50},
    {"Tire Air", "scr_carsteal4", "scr_carsteal5_tyre_spiked", 150},
    {"Tire Sparks", "scr_carsteal4", "scr_carsteal4_tyre_spikes", 50},
    {"Car Sparks", "core", "bang_carmetal", 250},
    {"Stungun Sparks", "core", "bul_stungun_metal", 500},
    {"Plane Sparks", "cut_exile1", "cs_ex1_plane_break_L", 325},
    {"Plane Debris", "scr_solomon3", "scr_trev4_747_engine_debris", 1000},
    {"Foundry Sparks", "core", "sp_foundry_sparks", 500},
    {"Foundry Steam", "core", "ent_amb_foundry_steam_spawn", 500},
    {"Oil", "core", "ent_sht_oil", 3500},
    {"Trash", "core", "ent_dst_hobo_trolley", 250},
    {"Money Trail", "scr_exec_ambient_fm", "scr_ped_foot_banknotes", 125},
    {"Gumball Machine", "core", "ent_dst_gen_gobstop", 500},
    {"Camera Flash", "scr_bike_business", "scr_bike_cfid_camera_flash", 200},
    {"Black Smoke", "scr_fbi4", "exp_fbi4_doors_post", 250},
    {"Musket", "wpn_musket", "muz_musket_ng", 500},
    {"Torpedo", "veh_stromberg", "exp_underwater_torpedo", 500},
    {"Molotov", "core", "exp_grd_molotov_lod", 500},
    {"EMP", "scr_xs_dr", "scr_xs_dr_emp", 350},
    {"Petrol Fire", "scr_finale1", "scr_fin_fire_petrol_trev", 2500},
    {"Petrol Explosion", "core", "exp_grd_petrol_pump", 300},
    {"Inflate", "core", "ent_dst_inflate_lilo", 300},
    {"Inflatable", "core", "ent_dst_inflatable", 500},
    {"Water Splash (Short)", "core", "ent_anim_bm_water_scp", 200},
    {"Water Splash (Long)", "cut_family5", "cs_fam5_michael_pool_splash", 500},
    {"Mop Squeeze", "scr_agencyheist", "scr_fbi_mop_squeeze", 100},
    {"Flame (Real)", "core", "ent_sht_flame", 7500}
}

PTFX.Request = function(asset)
    STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
        util.yield()
    end
end

PTFX.GetByName = function(name)
    for _, ptfx_data in pairs(PTFX.Types) do
        if ptfx_data[1] == name then return ptfx_data end
    end
    return nil
end

PTFX.CreateList = function(root, loop)
    for _, ptfx in pairs(PTFX.Types) do
        menu.toggle_loop(root, ptfx[1], {"ryan" .. ptfx[1]:lower()}, "Plays the " .. ptfx[1] .. " effect.", function()
            loop(ptfx)
        end)
    end
end

PTFX.PlayAtCoords = function(coords, ptfx_group, ptfx_name, color)
    PTFX.Request(ptfx_group)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
    if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
        ptfx_name, coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0, 1.0, 
        false, false, false
    )
end

PTFX.PlayOnEntity = function(entity, ptfx_group, ptfx_name, color)
    PTFX.Request(ptfx_group)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
    if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(
        ptfx_name, entity, 
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 
        false, false, false
    )
end

PTFX.PlayOnEntityBones = function(entity, bones, ptfx_group, ptfx_name, color)
    PTFX.Request(ptfx_group)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
    for _, bone in pairs(bones) do
        local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, bone)
        local coords = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, bone_index)
        if coords:magnitude() > 0 then
            GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_group)
            if color then GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(color.r, color.g, color.b) end
            GRAPHICS._START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                ptfx_name, entity,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                bone_index,
                1.0,
                false, false, false
            )
        end
    end
end

PTFX.PlayAtEntityBoneCoords = function(entity, bones, ptfx_group, name, color)
    for _, bone in pairs(bones) do
        local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, bone)
        local coords = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, bone_index)
        if coords:magnitude() > 0.0 then
            PTFX.PlayAtCoords(coords, ptfx_group, name, color)
        end
    end
end