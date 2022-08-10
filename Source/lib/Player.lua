Ryan.Player = {
    -- Search for a player by the start of their name, or a substring.
    GetId = function(search_name)
        local fallback_player_id = nil

        for _, player_id in pairs(players.list()) do
            local player_name = players.get_name(player_id)
            if player_name:lower() == search_name:lower() then return player_id end
            local substring_index = player_name:lower():find(search_name:lower())
            if substring_index == 1 then return player_id
            elseif substring_index ~= nil then fallback_player_id = player_id end
        end

        return fallback_player_id
    end,

    -- Kick a player using Stand's Smart kick, using Breakup if that fails.
    Kick = function(player_id)
        local player_name = players.get_name(player_id)
        menu.trigger_commands("kick" .. player_name)

        if menu.get_edition() >= 2 then
            util.yield(500)
            if Ryan.Player.GetId(player_name) ~= nil then menu.trigger_commands("breakup" .. player_name) end
        end
    end,
    
    -- Crash a player using both of Stand's crashes.
    Crash = function(player_id)
        local player_name = players.get_name(player_id)
        menu.trigger_commands("footlettuce" .. player_name)

        util.yield(250)
        menu.trigger_commands("ngcrash" .. player_name)
    end,

    SuperCrash = function(player_id, block_syncs)
        local player_ped = Ryan.Player.GetPed()
        local bush = util.joaat("h4_prop_bush_mang_ad")
        local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id))
        local starting_coords = ENTITY.GET_ENTITY_COORDS(player_ped)

        local crash = function()
            util.yield(100)

            ENTITY.SET_ENTITY_VISIBLE(player_ped, false)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(player_ped, coords.x, coords.y, coords.z, false, false, false)
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), bush)
            PED.SET_PED_COMPONENT_VARIATION(player_ped, 5, 8, 0, 0)
            util.yield(500)
            
            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user())
            util.yield(2000)

            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(player_ped, coords.x, coords.y, coords.z, false, false, false)
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), bush)
            PED.SET_PED_COMPONENT_VARIATION(player_ped, 5, 31, 0, 0)
            util.yield(500)

            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user())
            util.yield(2000)

            for i = 1, 5 do util.spoof_script("freemode", SYSTEM.WAIT) end
            ENTITY.SET_ENTITY_HEALTH(player_ped, 0)
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(starting_coords.x, starting_coords.y, starting_coords.z, 0, false, false, 0)
            ENTITY.SET_ENTITY_VISIBLE(player_ped, true)
        end

        if block_syncs then Ryan.Player.BlockSyncs(player_id, crash)
        else crash() end
    end,

    BlockSyncs = function(player_id, action)
        for _, id in pairs(players.list(false, true, true)) do
            if id ~= player_id then
                local outgoing_syncs = menu.ref_by_rel_path(menu.player_root(id), "Outgoing Syncs>Block")
                menu.trigger_command(outgoing_syncs, "on")
            end
        end
        util.yield(10)
        action()
        for _, id in pairs(players.list(false, true, true)) do
            if id ~= player_id then
                local outgoing_syncs = menu.ref_by_rel_path(menu.player_root(id), "Outgoing Syncs>Block")
                menu.trigger_command(outgoing_syncs, "off")
            end
        end
    end,

    -- Get a player's ped ID, or our own.
    GetPed = function(player_id)
        if not player_id then return players.user_ped() end
        return PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
    end,

    -- Get a player's index by their ped ID.
    GetByPed = function(ped_id)
        for _, player_id in pairs(players.list()) do
            if Ryan.Player.GetPed(player_id) == ped_id then
                return player_id
            end
        end
        return nil
    end,

    -- Get the total amount of money a player has.
    GetMoney = function(player_id)
        return players.get_wallet(player_id) + players.get_bank(player_id)
    end,

    -- Get whether a player is likely in godmode.
    IsInGodmode = function(player_id)
        return not players.is_in_interior(player_id) and players.is_godmode(player_id)
    end,

    -- Get whether a player is on an Oppressor Mk II.
    IsOnOppressor2 = function(player_id)
        return players.get_vehicle_model(player_id) == util.joaat("oppressor2")
    end,

    -- Teleport ourself.
    Teleport = function(coords, with_vehicle)
        util.toast("Teleporting...")
        local player_ped = Ryan.Player.GetPed()
        if with_vehicle and PED.IS_PED_IN_ANY_VEHICLE(player_ped, true) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
            ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z)
        else
            ENTITY.SET_ENTITY_COORDS(player_ped, coords.x, coords.y, coords.z)
        end
    end,

    -- Teleport a player's vehicle.
    TeleportVehicle = function(player_id, coords)
        local name = PLAYER.GET_PLAYER_NAME(player_id)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id), true)
        if vehicle ~= 0 then
            Ryan.Entity.RequestControl(vehicle, true)
            for i = 1, 3 do
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(vehicle, coords.x, coords.y, coords.z, false, false, false)
            end
        end
    end,

    -- Explode a player with or without Bed Sound.
    Explode = function(player_id, with_earrape)
        local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id))
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 100, true, false, 150, false)
        if with_earrape then
            Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
            coords.z = 2000.0
            Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
            coords.z = -2000.0
            Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
        end
    end,

    -- Kill a player in godmode using dark magic.
    Squish = function(player_id)
        util.toast("Attempting to kill " .. players.get_name(player_id) .. "...")

        local player_ped = Ryan.Player.GetPed(player_id)
        local coords = ENTITY.GET_ENTITY_COORDS(player_id)
        local distance = TASK.IS_PED_STILL(player_ped) and 0 or 3
        
        local vehicle = {["name"] = "Khanjali", ["height"] = 2.8, ["offset"] = 0}
                     -- {["name"] = "APC", ["height"] = 3.4, ["offset"] = -1.5}
        local vehicle_hash = util.joaat(vehicle.name)

        Ryan.Basics.RequestModel(vehicle_hash)    
        local vehicles = {
            entities.create_vehicle(vehicle_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, vehicle.offset, distance, vehicle.height), ENTITY.GET_ENTITY_HEADING(player_ped)),
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
    end,

    -- Send an SMS to a player.
    SMS = function(player_id, message)
        local player_name = players.get_name(player_id)
        menu.trigger_commands("smsrandomsender" .. player_name .. " on")
        menu.trigger_commands("smstext" .. player_name .. " " .. message)
        menu.trigger_commands("smssend")
    end,

    -- Spam SMS on a player.
    SpamSMS = function(player_id, message, duration)
        local player_name = players.get_name(player_id)
        menu.trigger_commands("smsrandomsender" .. player_name .. " on")
        menu.trigger_commands("smstext" .. player_name .. " " .. message)
        menu.trigger_commands("smsspam" .. player_name .. " on")
        util.yield(duration)
        menu.trigger_commands("smsspam" .. player_name .. " off")
    end,

    -- Spam SMS and block joins from a player, then perform a method. 
    SpamSMSAndBlockJoins = function(player_id, block_joins, sms_message, action)
        local player_name = players.get_name(player_id)
        if block_joins then
            menu.trigger_commands("historyblock" .. player_name)
        end
        if sms_message ~= "" and sms_message ~= " " then
            util.toast("Spamming " .. player_name .. " with texts...")
            Ryan.Player.SpamSMS(player_id, sms_message, 6000)
        end
        action()
        menu.trigger_commands("players")
    end,

    -- Send a script event to a player.
    SendScriptEvent = function(player_id, args, name)
        if name ~= nil then util.toast("Sending script event: " .. name .. "...") end
        util.trigger_script_event(1 << player_id, args)
        util.yield(10)
    end,

    -- Force player to become an animal via Halloween events.
    BecomeAnimal = function(player_id)
        Ryan.Player.SendScriptEvent(player_id, {-1178972880, player_id, 8, -1, 1, 1, 1}, "become an animal")
    end,

    -- Remove godmode via Force Camera Forward.
    RemoveGodmode = function(player_id)
        Ryan.Player.SendScriptEvent(player_id, {-1388926377, player_id, -1762807505, math.random(0, 9999)}, "remove godmode")
    end
}