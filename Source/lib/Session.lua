function session_explode_all(with_earrape)
    for _, player_id in pairs(players.list()) do
        local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id))
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 100, true, false, 150, false)
        
        if with_earrape then -- Credit: Bed Sound
            for i = 1, #BedSoundCoords do
                local coords = BedSoundCoords[i]
                audio_play_at_coords(coords, "WastedSounds", "Bed", 999999999)
                coords.z = 2000.0
                audio_play_at_coords(coords, "WastedSounds", "Bed", 999999999)
                coords.z = -2000.0
                audio_play_at_coords(coords, "WastedSounds", "Bed", 999999999)

                for _, player_id in pairs(players.list()) do
                    audio_play_at_coords(ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id)), "WastedSounds", "Bed", 999999999)
                end
            end
        end
    end
end

function session_spam_chat(message, all_players, time_between, wait_for)
    local sent = 0
    while sent < 32 do
        if all_players then
            for _, player_id in pairs(players.list()) do
                local name = players.get_name(player_id)
                menu.trigger_commands("chatas" .. name .. " on")
                chat.send_message(message, false, true, true)
                menu.trigger_commands("chatas" .. name .. " off")
                util.yield(time_between)
                sent = sent + 1
            end
        else
            chat.send_message(message, false, true, true)
            util.yield(time_between)
            sent = sent + 1
        end
    end
    util.yield(wait_for)
end

function session_translate_from(message)
    async_http.init("ryan.gq", "/menu/translate?text=" .. message .. "&language=EN", function(result)
        basics_show_text_message(Colors.Purple, "Translation", result)
    end, function()
        util.toast("Failed to translate message.")
    end)
    async_http.dispatch()
end

function session_translate_to(message, language, latin)
    async_http.init("ryan.gq", "/menu/translate?text=" .. message .. "&language=" .. language, function(result)
        if latin then
            for from, to in pairs(RussianAlphabet) do
                result = result:gsub(from, to)
            end
        end
        chat.send_message(result, false, true, true)
        util.toast("Sent!")
    end, function()
        util.toast("Failed to translate message.")
    end)
    async_http.dispatch()
end

function session_watch_and_takeover(action, player_id, wait_for)
    local player_name = players.get_name(player_id)
    menu.trigger_commands("tpveh" .. player_name)
    util.yield(750)

    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
    if vehicle ~= NULL then
        entity_request_control_loop(vehicle)
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
            action(vehicle)
            util.yield(wait_for)
        end
    end
end

function session_watch_and_takeover_all(action, modders, wait_for)
    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(), true)
    basics_show_text_message(Colors.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    for _, player_id in pairs(players.list()) do
        if player_id ~= players.user() and not players.is_in_interior(player_id) then
            if modders or not players.is_marked_as_modder(player_id) then
                session_watch_and_takeover(action, player_id, wait_for)
            end
        end
    end
    player_teleport_to(starting_coords.x, starting_coords.y, starting_coords.z)
    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
end

function session_watch_and_do_command_all(commands, modders, wait_for)
    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(), true)
    basics_show_text_message(Colors.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    menu.trigger_commands("levitation on")
    for _, player_id in pairs(players.list()) do
        if player_id ~= players.user() and not players.is_in_interior(player_id) then
            if modders or not players.is_marked_as_modder(player_id) then
                local player_name = players.get_name(player_id)
                menu.trigger_commands("tp" .. player_name)
                util.yield(1250)
                if player_name ~= "**invalid**" then
                    for i = 1, #commands do
                        menu.trigger_commands(commands[i]:gsub("{name}", player_name))
                    end
                end
                util.yield(wait_for)
            end
        end
    end
    player_teleport_to(starting_coords.x, starting_coords.y, starting_coords.z)
    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
    menu.trigger_commands("levitation off")
end