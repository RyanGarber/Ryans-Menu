-- General --
function player_get_ped(player_id)
    player_id = player_id or PLAYER.PLAYER_ID()
    return PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
end

function player_teleport_to(coords)
    util.toast("Teleporting...")
    ENTITY.SET_ENTITY_COORDS(player_get_ped(), coords.x, coords.y, coords.z)
end

function player_teleport_with_vehicle_to(coords)
    util.toast("Teleporting...")
    local player_ped = player_get_ped()
    if PED.IS_PED_IN_ANY_VEHICLE(player_ped, true) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
        ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z)
    else
        ENTITY.SET_ENTITY_COORDS(player_ped, coords.x, coords.y, coords.z)
    end
end

function player_get_money(player_id)
    return players.get_wallet(player_id) + players.get_bank(player_id)
end

function player_is_offradar(player_id)
    return players.is_otr(player_id)
end

function player_is_godmode(player_id)
    return not players.is_in_interior(player_id) and players.is_godmode(player_id)
end

function player_is_on_oppressor2(player_id)
    return players.get_vehicle_model(player_id) == util.joaat("oppressor2")
end

function player_remove_godmode(player_id, vehicle_too) -- Credit: KeramiScript
    if NETWORK.NETWORK_IS_PLAYER_CONNECTED(player_id) then
        if vehicle_too then
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
            if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
            end
        end
        util.trigger_script_event(1 << player_id, {801199324, player_id, 869796886})
    end
end

function player_block_joins(player_name) -- Credit: Block Joins Script
    local ref
    local possible_tags = {" [Offline/Story Mode]", " [Public]", " [Solo/Invite-Only]", ""}
    local success = false
    for i = 1, #possible_tags do
        if pcall(function()
            ref = menu.ref_by_path("Online>Player History>" .. player_name .. possible_tags[i] .. ">Player Join Reactions>Block Join")
        end) then
            menu.focus(menu.my_root())
            menu.trigger_command(ref, "true")
            success = true
            break
        end
    end
    if success then
        util.toast("Blocked all future joins by that player.")
    else
        util.toast("Failed to block joins.")
    end
end

function player_send_script_event(player_id, args, name)
    util.toast("Sending script event: " .. name .. "...")
    util.trigger_script_event(1 << player_id, args)
    util.yield(10)
end


-- Sorting Types --
function player_list_highest_and_lowest(get_value)
    local highest_amount = 0
    local highest_player = -1
    local lowest_amount = 2100000000
    local lowest_player = -1

    for _, player_id in pairs(players.list()) do
        amount = get_value(player_id)
        if amount > highest_amount and amount < 2100000000 then
            highest_amount = amount
            highest_player = player_id
        end
        if amount < lowest_amount and amount > 0 then
            lowest_amount = amount
            lowest_player = player_id
        end
    end

    return {highest_player, highest_amount, lowest_player, lowest_amount}
end

function player_list_by_boolean(get_value)
    local player_names = ""
    for _, player_id in pairs(players.list()) do
        if get_value(player_id) then
            player_names = player_names .. PLAYER.GET_PLAYER_NAME(player_id) .. ", "
        end
    end
    
    if player_names ~= "" then
        player_names = string.sub(player_names, 1, -3)
    end

    return player_names
end


-- Sorting Modes --
function player_list_by_money()
    data = player_list_highest_and_lowest(player_get_money)
    
    message = ""
    if data[1] ~= -1 then
        message = PLAYER.GET_PLAYER_NAME(data[1]) .. " is the richest player here ($" .. basics_format_int(data[2]) .. ")."
    end
    if data[1] ~= data[3] then
        message = message .. " " .. PLAYER.GET_PLAYER_NAME(data[3]) .. " is the poorest ($" .. basics_format_int(data[4]) .. ")."
    end
    if message ~= "" then
        chat.send_message(message, false, true, true)
        return
    end
end

function player_list_by_kd()
    data = player_list_highest_and_lowest(players.get_kd)
    
    message = ""
    if data[1] ~= -1 then
        message = PLAYER.GET_PLAYER_NAME(data[1]) .. " has the highest K/D here (" .. string.format("%.1f", data[2]) .. ")."
    end
    if data[1] ~= data[3] then
        message = message .. " " .. PLAYER.GET_PLAYER_NAME(data[3]) .. " has the lowest (" .. string.format("%.1f", data[4]) .. ")."
    end
    if message ~= "" then
        chat.send_message(message, false, true, true)
        return
    end
end

function player_list_by_godmode()
    local player_names = player_list_by_boolean(player_is_godmode)

    if player_names ~= "" then
        chat.send_message("Players likely in godmode: " .. player_names .. ".", false, true, true)
        return
    end

    chat.send_message("No players are in godmode.", false, true, true)
end

function player_list_by_offradar()
    local player_names = player_list_by_boolean(player_is_offradar)

    if player_names ~= "" then
        chat.send_message("Players off-the-radar: " .. player_names .. ".", false, true, true)
        return
    end

    chat.send_message("No players are off-the-radar.", false, true, true)
end

function player_list_by_oppressor2()
    local player_names = player_list_by_boolean(player_is_on_oppressor2)

    if player_names ~= "" then
        chat.send_message("Players on Oppressors: " .. player_names .. ".", false, true, true)
        return
    end

    chat.send_message("No players are on Oppressors.", false, true, true)
end


-- Trolling --
function player_do_sms_spam(player_id, message, duration)
    local player_name = players.get_name(player_id)
    menu.trigger_commands("smsrandomsender" .. player_name .. " on")
    menu.trigger_commands("smstext" .. player_name .. " " .. message)
    menu.trigger_commands("smsspam" .. player_name .. " on")
    util.yield(duration)
    menu.trigger_commands("smsspam" .. player_name .. " off")
end

function player_spam_and_block(player_id, removal_block_joins, removal_message, action)
    local player_name = players.get_name(player_id)
    if removal_block_joins then
        player_block_joins(player_name)
    end
    if removal_message ~= "" and removal_message ~= " " then
        util.toast("Spamming " .. player_name .. " with texts...")
        player_do_sms_spam(player_id, removal_message, 6000)
    end
    action()
    menu.trigger_commands("players")
end

function player_fake_money_drop(player_id)
    menu.trigger_commands("notifybanked" .. players.get_name(player_id) .. " " .. math.random(100, 5000))
    local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id))
    local bag = entities.create_object(2628187989, vector_add(coords, {x = 0, y = 0, z = 2}))
    ENTITY.APPLY_FORCE_TO_ENTITY(bag, 3, 0, 0, -20, 0.0, 0.0, 0.0, true, true)
    util.yield(333)
    AUDIO.PLAY_SOUND_FROM_COORD(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", coords.x, coords.y, coords.z, "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 2, false)
    entities.delete_by_handle(bag)
end

function player_trash_pickup(player_id)
    util.toast("Sending the trash man to " .. players.get_name(player_id) .. "...")

    local trash_truck = util.joaat("trash"); basics_request_model(trash_truck)
    local trash_man = util.joaat("s_m_y_garbage"); basics_request_model(trash_man)
    local player_ped = player_get_ped(player_id)
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)

    local weapons = {"weapon_pistol", "weapon_pumpshotgun"}
    local coords_ptr = memory.alloc()
    local node_ptr = memory.alloc()

    if not PATHFIND.GET_RANDOM_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, 80, 0, 0, 0, coords_ptr, node_ptr) then
        player_coords.x = player_coords.x + math.random(-7, 7)
        player_coords.y = player_coords.y + math.random(-7, 7)
        PATHFIND.GET_CLOSEST_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, coords_ptr, 1, 100, 2.5)
    end

    local coords = memory.read_vector3(coords_ptr); memory.free(coords_ptr); memory.free(node_ptr)
    local vehicle = entities.create_vehicle(trash_truck, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    entity_face_entity(vehicle, player_ped, true)
    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)

    for seat = -1, 2 do
        local npc = entities.create_ped(5, trash_man, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        local weapon = basics_get_random(weapons)

        PED.SET_PED_RANDOM_COMPONENT_VARIATION(npc, 0)
        WEAPON.GIVE_WEAPON_TO_PED(npc, util.joaat(weapon) , -1, false, true)
        PED.SET_PED_NEVER_LEAVES_GROUP(npc, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 1, true)
        PED.SET_PED_INTO_VEHICLE(npc, vehicle, seat)
        ENTITY.SET_ENTITY_INVINCIBLE(npc, false)
        TASK.TASK_COMBAT_PED(npc, player_ped, 0, 16)
        PED.SET_PED_KEEP_TASK(npc, true)

        util.create_tick_handler(function()
            if TASK.GET_SCRIPT_TASK_STATUS(npc, 0x2E85A751) == 7 then
                TASK.CLEAR_PED_TASKS(npc)
                TASK.TASK_SMART_FLEE_PED(npc, player_get_ped(player_id), 1000.0, -1, false, false)
                PED.SET_PED_KEEP_TASK(npc, true)
                return false
            end
            return true
        end)
    end
    
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(trash_truck)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(trash_man)

    player_do_sms_spam(player_id, "It's trash day! Time to take it out.", 5000)
end

function player_go_karts(player_id, ped_type)
    local player_ped = player_get_ped(player_id)
    local veto = util.joaat("veto2"); basics_request_model(veto)
    local driver = util.joaat(ped_type); basics_request_model(driver)
    for i = 1, 4 do
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 5 - i, -10.0, 0.0)
        local vehicle = entities.create_vehicle(veto, coords, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i = -1, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(veto) - 2 do
            local ped = entities.create_ped(1, driver, coords, 0.0)
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(ped, player_ped)
            end
            vehicle_set_upgraded(vehicle, true)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, i)
            WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_appistol"), 1000, false, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
            TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
        end
    end
end

function player_flying_yacht(player_id)
    local yacht = util.joaat("prop_cj_big_boat"); basics_request_model(yacht)
    local buzzard = util.joaat("buzzard2"); basics_request_model(buzzard)
    local black_ops = util.joaat("s_m_y_blackops_01"); basics_request_model(black_ops)
    local army = util.joaat("ARMY")

    local player_ped =  player_get_ped(player_id)
    local player_group = PED.GET_PED_RELATIONSHIP_GROUP_HASH(player_ped)
    local coords = ENTITY.GET_ENTITY_COORDS(player_ped)

    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, army, player_group)
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, player_group, army)
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, army, army)

    local vehicle = entities.create_vehicle(buzzard, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    local attachment = entities.create_object(yacht, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.VEH_TO_NET(vehicle), false)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) then
        local ped = entities.create_ped(29, black_ops, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
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
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)
            WEAPON.GIVE_WEAPON_TO_PED(ped, 3686625920, -1, false, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)
            PED.SET_PED_MAX_HEALTH(ped, 500)
            ENTITY.SET_ENTITY_HEALTH(ped, 500)
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
            PED.SET_PED_SHOOT_RATE(ped, 1000)
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, army)
            TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 1000, 0)
        end

        util.yield(100)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(yacht)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(buzzard)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(black_ops)
end

-- Crashes --
function player_crash_to_singleplayer(player_id)
    basics_show_text_message(Colors.Purple, "Crash To Singleplayer", "Now sending script events. This may take a while...")
    local events = basics_shuffle(CrashEvents)
    for _, event in pairs(events) do
        player_send_script_event(player_id, event, "Crash To Singleplayer")
    end
end

function player_crash_to_desktop(player_id, mode)
    if not mode then
        for _, crash_mode in pairs(CrashToDesktopModes) do
            util.create_thread(function()
                player_crash_to_desktop(player_id, crash_mode)
            end)
        end
        return
    end

    local player_ped = player_get_ped(player_id)
    local player_ped_heading = ENTITY.GET_ENTITY_HEADING(player_ped)
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)

    basics_show_text_message(Colors.Purple, "Crash To Desktop", "Now spawning entities. This may take a while...")
    for _, crash_mode in pairs(CrashToDesktopModes) do
        if mode == crash_mode then util.toast("Beginning crash: " .. crash_mode .. ".") end
    end

    if mode == "Yo Momma" then
        local fatcult = util.joaat("a_f_m_fatcult_01"); basics_request_model(fatcult)
        for i = 1, 8 do
            util.create_thread(function()
                local ped = entities.create_ped(
                    0, fatcult,
                    vector_add(player_coords, {x = math.random(-1, 1), y = math.random(-1, 1), z = 0}),
                    player_ped_heading
                )
                util.yield(400)
                entities.delete_by_handle(ped)
            end)
            util.yield(100)
            local ped_1 = entities.create_ped(0, util.joaat("slod_human"), player_coords, player_ped_heading)
            local ped_2 = entities.create_ped(0, util.joaat("slod_large_quadped"), player_coords, player_ped_heading)
            local ped_3 = entities.create_ped(0, util.joaat("slod_small_quadped"), player_coords, player_ped_heading)
            util.yield(750)
            entities.delete_by_handle(ped_1)
            entities.delete_by_handle(ped_2)
            entities.delete_by_handle(ped_3)
            player_send_script_event(player_id, {962740265, player_id, 23243, 5332, 3324, player_id}, "final payload")
        end
    end

    if mode == "Vegetation" then
        basics_request_model(-930879665)
        basics_request_model(3613262246)
        basics_request_model(452618762)
        local object_1 = entities.create_object(-930879665, player_coords)
        util.yield(10)
        local object_2 = entities.create_object(3613262246, player_coords)
        util.yield(10)
        local object_3 = entities.create_object(452618762, player_coords)
        util.yield(10)
        local object_4 = entities.create_object(3613262246, player_coords)
        util.yield(300)
        entities.delete_by_handle(object_1)
        entities.delete_by_handle(object_2)
        entities.delete_by_handle(object_3)
        entities.delete_by_handle(object_4)
    end

    if mode == "Invalid Objects" then
        local hashes = basics_shuffle(InvalidObjectsHashes)
        local objects = {}
        for _, hash in pairs(hashes) do table.insert(objects, entities.create_object(hash, player_coords)) end
        util.yield(5000)
        for _, object in pairs(objects) do entities.delete_by_handle(object) end
    end

    if mode == "Invalid Peds" then
        local ped = entities.create_ped(0, 1057201338, player_coords, 0)
        util.yield(100)
        entities.delete_by_handle(ped)
        local ped = entities.create_ped(0, -2056455422, player_coords, 0)
        util.yield(100)
        entities.delete_by_handle(ped)
        local ped = entities.create_ped(0, 762327283, player_coords, 0)
        util.yield(100)
        entities.delete_by_handle(ped)
    end
end