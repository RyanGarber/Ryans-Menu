Ryan.Trolling = {
    Entities = {},

    AddEntity = function(player_id, entity, with_blip)
        if Ryan.Trolling.Entities[player_id] == nil then Ryan.Trolling.Entities[player_id] = {} end
        table.insert(Ryan.Trolling.Entities[player_id], entity)
        if with_blip then HUD.ADD_BLIP_FOR_ENTITY(entity) end
    end,

    DeleteEntities = function(player_id)
        if Ryan.Trolling.Entities[player_id] == nil then return end

        for _, entity in pairs(Ryan.Trolling.Entities[player_id]) do entities.delete_by_handle(entity) end
        Ryan.Trolling.Entities[player_id] = {}
    end,

    MilitarySquad = function(player_id, with_crusaders)
        local player_ped = Ryan.Player.GetPed(player_id)
        local player_group = PED.GET_PED_RELATIONSHIP_GROUP_HASH(player_ped)
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)

        local black_ops = util.joaat("s_m_y_blackops_01"); Ryan.Basics.RequestModel(black_ops)
        local army = util.joaat("army")
        local vehicles = with_crusaders and {"apc", "apc", "crusader", "crusader", "crusader"} or {"apc", "apc"}

        for i = 1, #vehicles do
            vehicles[i] = util.joaat(vehicles[i])
            Ryan.Basics.RequestModel(vehicles[i])
        end

        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, army, player_group)
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, player_group, army)
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, army, army)

        for i = 1, #vehicles do
            local coords_ptr = memory.alloc()
            local node_ptr = memory.alloc()

            if not PATHFIND.GET_RANDOM_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, 80, 0, 0, 0, coords_ptr, node_ptr) then
                player_coords.x = player_coords.x + math.random(-20, 20)
                player_coords.y = player_coords.y + math.random(-20, 20)
                PATHFIND.GET_CLOSEST_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, coords_ptr, 1, 100, 2.5)
            end

            local coords = memory.read_vector3(coords_ptr)
            local vehicle = entities.create_vehicle(vehicles[i], coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
            Ryan.Trolling.AddEntity(player_id, vehicle, i < 3)
            Ryan.Entity.FaceEntity(vehicle, player_ped, true)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
            Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Fast)
            Ryan.Vehicle.SetFullyUpgraded(vehicle, true)

            local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vehicles[i])
            for seat = -1, seats - 2 do
                local ped = entities.create_ped(29, black_ops, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
                Ryan.Trolling.AddEntity(player_id, ped, false)
                PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)
                WEAPON.GIVE_WEAPON_TO_PED(ped, 3686625920, -1, false, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)
                PED.SET_PED_MAX_HEALTH(ped, 500)
                ENTITY.SET_ENTITY_HEALTH(ped, 500)
                PED.SET_PED_SHOOT_RATE(ped, 1000)
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, army)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 1000, 0)
            end
        end

        for i = 1, #vehicles do STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicles[i]) end
    end,

    SWATTeam = function(player_id)
        local player_ped = Ryan.Player.GetPed(player_id)
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        local player_group = PED.GET_PED_RELATIONSHIP_GROUP_HASH(player_ped)

        local swat = util.joaat("s_m_y_swat_01"); Ryan.Basics.RequestModel(swat)
        local army = util.joaat("army")

        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, army, player_group)
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, player_group, army)
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, army, army)
        
        for i = 1, 4 do
            local coords = Ryan.Vector.Add(player_coords, {x = math.random(-3, 3), y = math.random(-3, 3), z = 0})
            local ped = entities.create_ped(5, swat, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
            Ryan.Trolling.AddEntity(player_id, ped, i == 1)

            WEAPON.GIVE_WEAPON_TO_PED(ped, -1312131151, -1, false, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)
            PED.SET_PED_MAX_HEALTH(ped, 500)
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
            PED.SET_PED_SHOOT_RATE(ped, 1000)
            WEAPON.SET_PED_INFINITE_AMMO(ped, true, -1312131151)
            WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, army)
            TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 100, 0)
            util.yield(375)
        end

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(swat)
    end,

    FlyingYacht = function(player_id)
        local yacht = util.joaat("prop_cj_big_boat"); Ryan.Basics.RequestModel(yacht)
        local buzzard = util.joaat("buzzard2"); Ryan.Basics.RequestModel(buzzard)
        local black_ops = util.joaat("s_m_y_blackops_01"); Ryan.Basics.RequestModel(black_ops)
        local army = util.joaat("army")

        local player_ped =  Ryan.Player.GetPed(player_id)
        local player_group = PED.GET_PED_RELATIONSHIP_GROUP_HASH(player_ped)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped)

        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, army, player_group)
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, player_group, army)
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, army, army)

        local vehicle = entities.create_vehicle(buzzard, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        local attachment = entities.create_object(yacht, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        Ryan.Trolling.AddEntity(player_id, attachment, false); Ryan.Trolling.AddEntity(player_id, vehicle, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.VEH_TO_NET(vehicle), false)
        if ENTITY.DOES_ENTITY_EXIST(vehicle) then
            local ped = entities.create_ped(29, black_ops, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
            Ryan.Trolling.AddEntity(player_id, ped, false)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle)
            
            coords.x = coords.x + math.random(-20, 20)
            coords.y = coords.y + math.random(-20, 20)
            coords.z = coords.z + 30
            ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.VEH_TO_NET(vehicle), false)
            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehicle)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(attachment, vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "chassis"), 0, 0, 0, 0, 0, 0, false, false, false, false, 0, true)
            HUD.ADD_BLIP_FOR_ENTITY(vehicle)

            PED.SET_PED_MAX_HEALTH(ped, 500)
            ENTITY.SET_ENTITY_HEALTH(ped, 500)
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
            TASK.TASK_HELI_MISSION(ped, vehicle, 0, player_ped, 0.0, 0.0, 0.0, 23, 40.0, 40.0, -1.0, 0, 10, -1.0, 0)
            PED.SET_PED_KEEP_TASK(ped, true)

            for seat = 1, 2 do 
                local ped = entities.create_ped(29, black_ops, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
                Ryan.Trolling.AddEntity(player_id, ped, false)
                PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)
                WEAPON.GIVE_WEAPON_TO_PED(ped, 3686625920, -1, false, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)
                PED.SET_PED_MAX_HEALTH(ped, 500)
                ENTITY.SET_ENTITY_HEALTH(ped, 500)
                PED.SET_PED_SHOOT_RATE(ped, 1000)
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, army)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 1000, 0)
            end

            util.yield(100)
        end

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(yacht)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(buzzard)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(black_ops)
    end,

    FallingTank = function(player_id)
        local player_ped = Ryan.Player.GetPed(player_id)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        coords.z = coords.z + 5

        local tank = util.joaat("rhino"); Ryan.Basics.RequestModel(tank)
        local entity = entities.create_vehicle(tank, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        Ryan.Trolling.AddEntity(player_id, entity, true)
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(entity, true)
        ENTITY.SET_ENTITY_MAX_SPEED(entity, 64)
        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 3, 0.0, 0.0, -1000.00, 0.0, 0.0, 0.0, 0, true, true, false, true)
        Ryan.Basics.FreeModel(tank)
    end,

    FakeMoneyDrop = function(player_id)
        menu.trigger_commands("notifybanked" .. players.get_name(player_id) .. " " .. math.random(100, 5000))
        local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id))
        local bag = entities.create_object(2628187989, Ryan.Vector.Add(coords, {x = 0, y = 0, z = 2}))
        ENTITY.APPLY_FORCE_TO_ENTITY(bag, 3, 0, 0, -20, 0.0, 0.0, 0.0, true, true)
        util.yield(333)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", coords.x, coords.y, coords.z, "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 2, false)
        entities.delete_by_handle(bag)
    end,

    CreateNASAMenu = function(root, player_id)
        local command = "ryannasa" .. (not player_id and "all" or "")
        local message = "who asked"
        local nasa_root = menu.list(root, "NASA Satellite...", {command}, "Use NASA satellites to discover something.")
    
        menu.text_input(nasa_root, "To Find", {command .. "message"}, "What we're trying to find.", function(value)
            message = value
        end, "who asked")
    
        function go(player_id)
            local hash = util.joaat("prop_air_bigradar")
            Ryan.Basics.RequestModel(hash)
    
            local player_ped = Ryan.Player.GetPed(player_id)
            local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
            local radar = entities.create_object(hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0, 20, -3), ENTITY.GET_ENTITY_HEADING(player_ped))
            Ryan.Entity.RequestControl(radar, false)
            Ryan.Trolling.AddEntity(player_id, radar, true)
            
            util.yield(10000)
            entities.delete_by_handle(radar)
        end
        
        menu.action(nasa_root, "Go", {command .. "go"}, "Spawn a NASA satellite to discover something.", function()
            if player_id then go(player_id)
            else for _, player_id in pairs(players.list()) do util.create_thread(function() go(player_id) end) end end
            chat.send_message("Using NASA satellites to find " .. message .. ".", false, true, true)
        end)
    end
}