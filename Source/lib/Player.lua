-- General --
function player_get_ped(player_id)
    player_id = player_id or PLAYER.PLAYER_ID()
    return PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
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
            menu.focus(ref)
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
        message = PLAYER.GET_PLAYER_NAME(data[1]) .. " is the richest player here ($" .. format_int(data[2]) .. ")."
    end
    if data[1] ~= data[3] then
        message = message .. " " .. PLAYER.GET_PLAYER_NAME(data[3]) .. " is the poorest ($" .. format_int(data[4]) .. ")."
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