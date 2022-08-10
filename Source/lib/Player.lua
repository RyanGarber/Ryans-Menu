Ryan.Player = {Instances = {}}

-- Get our own player.
Ryan.Player.Self = function()
    if Ryan.Player.Instances[players.user()] == nil then return nil end
    return Ryan.Player.Instances[players.user()].update()
end

-- Get a player by its index.
Ryan.Player.Get = function(id)
    if Ryan.Player.Instances[id] == nil then return nil end
    return Ryan.Player.Instances[id].update()
end

-- Get a player by its ped ID.
Ryan.Player.ByPedId = function(ped_id)
    for _, player in pairs(Ryan.Player.List(true, true, true)) do
        if player.ped_id == ped_id then return player end
    end
    return nil
end

-- Get a player by the start of its name, or a substring.
Ryan.Player.ByName = function(name)
    local fallback_player = nil

    for _, player in pairs(Ryan.Player.List(true, true, true)) do
        if player.name:lower() == name:lower() then return player end
        local substring_index = player.name:lower():find(name:lower())
        if substring_index == 1 then return player
        elseif substring_index ~= nil then fallback_player = player end
    end

    return fallback_player
end

-- List all players in the session.
Ryan.Player.List = function(include_self, include_friends, include_modders)
    local player_list = {}
    for _, player in pairs(Ryan.Player.Instances) do
        if (include_self or player.id ~= players.user())
        and (include_friends or not menu.get_tags_string(player.id):find("F"))
        and (include_modders or not menu.is_marked_as_modder(player.id)) then
            table.insert(player_list, player.update())
        end
    end
    return player_list
end

-- Create a new player object.
Ryan.Player.New = function(player_id)
    local player = {id = player_id, state = {}}

    -- Kick a player using Stand's Smart kick, using Breakup if that fails.
    player.kick = function()
        local player_name = player.name
        menu.trigger_commands("kick" .. player_name)
        if menu.get_edition() >= 2 then
            util.yield(500)
            if Ryan.Player.ByName(player_name) ~= nil then menu.trigger_commands("breakup" .. player.name) end
        end
    end
    
    -- Crash a player using both of Stand's crashes.
    player.crash = function()
        util.toast("Crashing a player...")
        menu.trigger_commands("footlettuce" .. player.name)
        util.yield(250)
        menu.trigger_commands("ngcrash" .. player.name)
    end

    -- Crash a player using a bugged parachute model.
    player.super_crash = function(block_syncs)
        util.toast("Crashing a player...")
        local ourself = Ryan.Player.Self()
        local bush = util.joaat("h4_prop_bush_mang_ad")
        local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)
        local starting_coords = ENTITY.GET_ENTITY_COORDS(ourself.ped_id)

        local crash = function()
            util.yield(100)

            ENTITY.SET_ENTITY_VISIBLE(ourself.ped_id, false)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ourself.ped_id, coords.x, coords.y, coords.z, false, false, false)
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), bush)
            PED.SET_PED_COMPONENT_VARIATION(ourself.ped_id, 5, 8, 0, 0)
            util.yield(500)
            
            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user())
            util.yield(2000)

            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ourself.ped_id, coords.x, coords.y, coords.z, false, false, false)
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), bush)
            PED.SET_PED_COMPONENT_VARIATION(ourself.ped_id, 5, 31, 0, 0)
            util.yield(500)

            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user())
            util.yield(2000)

            for i = 1, 5 do util.spoof_script("freemode", SYSTEM.WAIT) end
            ENTITY.SET_ENTITY_HEALTH(ourself.ped_id, 0)
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(starting_coords.x, starting_coords.y, starting_coords.z, 0, false, false, 0)
            ENTITY.SET_ENTITY_VISIBLE(ourself.ped_id, true)
        end

        if block_syncs then player.do_with_exclusive_syncs(crash)
        else crash() end
    end

    -- Perform an action while blocking syncs to other players.
    player.do_with_exclusive_syncs = function(action)
        for _, id in pairs(players.list(false, true, true)) do
            if id ~= player.id then Ryan.Player.Get(id).block_syncs(true) end
        end
        util.yield(10)
        action()
        for _, id in pairs(players.list(false, true, true)) do
            if id ~= player.id then Ryan.Player.Get(id).block_syncs(false) end
        end
    end

    -- Block syncs to this player.
    player.block_syncs = function(block)
        util.toast((block and "Blocked" or "Unblocked") .. " syncs with " .. player.name .. ".")
        local outgoing_syncs = menu.ref_by_rel_path(menu.player_root(id), "Outgoing Syncs>Block")
        menu.trigger_command(outgoing_syncs, block and "on" or "off")
    end

    -- Get the seat the player is in.
    player.get_vehicle_seat = function()
        local vehicle_model = players.get_vehicle_model(player.id)
        if vehicle_model ~= 0 then
            local vehicle_id = PED.GET_VEHICLE_PED_IS_IN(player.ped_id, true)
            local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vehicle_model)
            for seat = -1, seats - 2 do
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle_id, seat) == player.ped_id then return seat end
            end
        end
        return nil
    end

    -- Get whether a player is likely in godmode.
    player.is_in_godmode = function()
        return not players.is_in_interior(player.id) and players.is_godmode(player.id)
    end

    -- Get whether a player is on an Oppressor Mk II.
    player.is_on_oppressor2 = function()
        return players.get_vehicle_model(player.id) == util.joaat("oppressor2")
    end

    -- Get the player's coordinates.
    player.get_coords = function()
        return ENTITY.GET_ENTITY_COORDS(player.ped_id)
    end

    -- Teleport a player's vehicle.
    player.teleport_vehicle = function(coords)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player.ped_id, true)
        if vehicle ~= 0 then
            Ryan.Entity.RequestControl(vehicle, true)
            for i = 1, 3 do
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(vehicle, coords.x, coords.y, coords.z, false, false, false)
            end
        end
    end

    -- Explode a player with or without Bed Sound.
    player.explode = function(with_earrape)
        local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 100, true, false, 150, false)
        if with_earrape then
            Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
            coords.z = 2000.0
            Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
            coords.z = -2000.0
            Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
        end
    end

    -- Kill a player in godmode using dark magic.
    player.squish = function()
        util.toast("Attempting to kill " .. player.name .. "...")

        local coords = ENTITY.GET_ENTITY_COORDS(player.id)
        local distance = TASK.IS_PED_STILL(player.ped_id) and 0 or 3
        local vehicle = {["name"] = "Khanjali", ["height"] = 2.8, ["offset"] = 0}  -- {["name"] = "APC", ["height"] = 3.4, ["offset"] = -1.5}
        local vehicle_hash = util.joaat(vehicle.name)

        Ryan.Basics.RequestModel(vehicle_hash)    
        local vehicles = {
            entities.create_vehicle(vehicle_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.ped_id, vehicle.offset, distance, vehicle.height), ENTITY.GET_ENTITY_HEADING(player.ped_id)),
            entities.create_vehicle(vehicle_hash, coords, 0),
            entities.create_vehicle(vehicle_hash, coords, 0),
            entities.create_vehicle(vehicle_hash, coords, 0)
        }
        for i = 1, #vehicles do Ryan.Entity.RequestControl(vehicles[i]) end  
        
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicles[2], vehicles[1], 0, 0, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicles[3], vehicles[1], 0, 3, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicles[4], vehicles[1], 0, 3, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
        ENTITY.SET_ENTITY_VISIBLE(vehicles[1], false)

        util.yield(7500)
        for i = 1, #vehicles do entities.delete_by_handle(vehicles[i]) end
    end

    -- Send an SMS to a player.
    player.send_sms = function(message)
        menu.trigger_commands("smstext" .. player.name .. " " .. message)
        menu.trigger_commands("smssend" .. player.name)
    end

    -- Spam SMS on a player.
    player.spam_sms = function(message, duration)
        local start_time = util.current_time_millis()
        util.create_thread(function()
            while util.current_time_millis() - start_time < duration do
                player.send_sms(message)
                util.yield()
            end
        end)
    end

    -- Spam SMS and block joins from a player, then perform a method. 
    player.spam_sms_and_block_joins = function(block_joins, sms_message, action)
        if block_joins then
            menu.trigger_commands("historyblock" .. player.name)
        end
        if sms_message ~= "" and sms_message ~= " " then
            util.toast("Spamming " .. player.name .. " with texts...")
            player.spam_sms(sms_message, 6000)
        end
        action()
        menu.trigger_commands("players")
    end

    -- Send a script event to a player.
    player.send_script_event = function(args, name)
        if name ~= nil then util.toast("Sending script event: " .. name .. "...") end
        util.trigger_script_event(1 << player.id, args)
        util.yield(10)
    end

    -- Force player to become an animal via Halloween events.
    player.turn_into_animal = function()
        if PED.IS_PED_MODEL(player.ped_id, 0x9C9EFFD8) or PED.IS_PED_MODEL(player.ped_id, 0x705E61F2) then
            player.send_script_event({-1178972880, player.id, 8, -1, 1, 1, 1}, "halloween")
        end
    end

    -- Remove godmode via Force Camera Forward.
    player.remove_godmode = function()
        player.send_script_event({-1388926377, player.id, -1762807505, math.random(0, 9999)}, "remove godmode")
    end

    -- Update cache.
    player.update = function()
        player.name = players.get_name(player.id)
        player.ped_id = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player.id)
        player.ped_group = PED.GET_PED_RELATIONSHIP_GROUP_HASH(player.ped_id)
        return player
    end

    return player.update()
end

-- Handle player object creation.
players.on_join(function(player_id)
    Ryan.Player.Instances[player_id] = Ryan.Player.New(player_id)
    if Ryan.Player.OnJoin ~= nil then Ryan.Player.OnJoin(Ryan.Player.Instances[player_id]) end
end)
players.on_leave(function(player_id)
    if Ryan.Player.OnLeave ~= nil then Ryan.Player.OnLeave(Ryan.Player.Instances[player_id]) end
    Ryan.Player.Instances[player_id] = nil
end)

util.create_tick_handler(function()
    local player_count = 0
    for _, player in pairs(Ryan.Player.Instances) do player_count = player_count + 1 end
end)