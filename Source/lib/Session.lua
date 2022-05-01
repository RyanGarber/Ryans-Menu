function session_explode_all(with_earrape)
    if with_earrape then -- Credit: Bed Sound
        for i = 1, #BedSoundCoords do
            local coords = BedSoundCoords[i]
            audio_play_at_coords(coords, "WastedSounds", "Bed", 999999999)
            coords.z = 2000.0
            audio_play_at_coords(coords, "WastedSounds", "Bed", 999999999)
            coords.z = -2000.0
            audio_play_at_coords(coords, "WastedSounds", "Bed", 999999999)
        end
    end
    
    for _, player_id in pairs(players.list()) do
        player_explode(player_id, with_earrape)
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
        basics_show_text_message(Color.Purple, "Translation", result)
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
    if vehicle ~= 0 then
        entity_request_control_loop(vehicle, "session trolling")
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
            action(vehicle)
            util.yield(wait_for)
        end
    end
end

session_watch_in_progress = false
function session_watch_cancel()
    if session_watch_in_progress then
        session_watch_in_progress = false
        basics_show_text_message(Color.Purple, "Session Trolling", "The mass troll has been cancelled, and will end after this player.")
    else
        basics_show_text_message(Color.Red, "Session Trolling", "There is no mass troll to cancel.")
    end
end

function session_watch_and_takeover_all(action, modders, wait_for)
    if session_watch_in_progress then
        basics_show_text_message(Color.Red, "Session Trolling", "Mass trolling is already in progress. Wait for it to end or stop it.")
        return
    end

    session_watch_in_progress = true
    basics_show_text_message(Color.Purple, "Session Trolling", "Mass trolling has begun. Sit tight and enjoy the show!")

    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    
    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(), true)
    for _, player_id in pairs(players.list()) do
        if not session_watch_in_progress then break end
        if player_id ~= players.user() and not players.is_in_interior(player_id) then
            if modders or not players.is_marked_as_modder(player_id) then
                session_watch_and_takeover(action, player_id, wait_for)
            end
        end
    end
    player_teleport_to(starting_coords)

    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")

    session_watch_in_progress = false
    basics_show_text_message(Color.Purple, "Session Trolling", "Mass trolling has finished trying all players.")
end

function session_watch_and_do_command_all(commands, modders, wait_for)
    if session_watch_in_progress then
        basics_show_text_message(Color.Red, "Session Trolling", "Mass trolling is already in progress. Wait for it to end or stop it.")
        return
    end

    session_watch_in_progress = true
    basics_show_text_message(Color.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
    
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    menu.trigger_commands("levitation on")

    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(), true)
    for _, player_id in pairs(players.list()) do
        if not session_watch_in_progress then break end
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
    player_teleport_to(starting_coords)

    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
    menu.trigger_commands("levitation off")

    session_watch_in_progress = false
end

function session_watch_and_do_all(action, modders, wait_for)
    if session_watch_in_progress then
        basics_show_text_message(Color.Red, "Session Trolling", "Mass trolling is already in progress. Wait for it to end or stop it.")
        return
    end

    session_watch_in_progress = true
    basics_show_text_message(Color.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
    
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    menu.trigger_commands("levitation on")

    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(), true)
    for _, player_id in pairs(players.list()) do
        if not session_watch_in_progress then break end
        if player_id ~= players.user() and not players.is_in_interior(player_id) then
            if modders or not players.is_marked_as_modder(player_id) then
                local player_name = players.get_name(player_id)
                menu.trigger_commands("tp" .. player_name)
                util.yield(1250)
                if player_name ~= "**invalid**" then
                    action(player_id)
                end
                util.yield(wait_for)
            end
        end
    end
    player_teleport_to(starting_coords)

    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
    menu.trigger_commands("levitation off")

    session_watch_in_progress = false
end