Ryan.Session = {}

-- Sorting Types --
Ryan.Session.ListHighestAndLowest = function(get_value)
    local highest_amount = 0
    local highest_player = nil
    local lowest_amount = 2147483647
    local lowest_player = nil

    for _, player_id in pairs(players.list()) do
        local player = Ryan.Player.Get(player_id)
        amount = get_value(player)
        if amount > highest_amount and amount < 2147483647 then
            highest_amount = amount
            highest_player = player
        end
        if amount < lowest_amount and amount > 0 then
            lowest_amount = amount
            lowest_player = player
        end
    end

    return {
        highest = {amount = highest_amount, player = highest_player},
        lowest = {amount = lowest_amount, player = lowest_player}
    }
end

Ryan.Session.ListByBoolean = function(get_value)
    local players = {}

    for _, player in pairs(Ryan.Player.List(true, true, true)) do
        if get_value(player) then
            table.insert(players, player)
        end
    end

    return players
end

-- Sorting Modes --
Ryan.Session.ListByMoney = function()
    local data = Ryan.Session.ListHighestAndLowest(function(player) return players.get_money(player.id) end)

    message = ""
    if data[1] ~= -1 then
        message = data.highest.player.name .. " is the richest player here ($" .. Ryan.FormatNumber(data.highest.amount) .. ")."
    end
    if data[1] ~= data[3] then
        message = message .. " " .. data.lowest.player.name .. " is the poorest ($" .. Ryan.FormatNumber(data.lowest.amount) .. ")."
    end

    if message ~= "" then
        Ryan.SendChatMessage(message)
        return
    end
end

Ryan.Session.ListByKD = function()
    data = Ryan.Session.ListHighestAndLowest(function(player) return players.get_kd(player.id) end)
    message = ""

    if data[1] ~= -1 then
        message = data.highest.player.name .. " has the highest K/D here (" .. string.format("%.1f", data.highest.amount) .. ")."
    end
    if data[1] ~= data[3] then
        message = message .. " " .. data.lowest.player.name .. " has the lowest (" .. string.format("%.1f", data.lowest.amount) .. ")."
    end
    
    if message ~= "" then
        Ryan.SendChatMessage(message)
        return
    end
end

Ryan.Session.ListByInGodmode = function()
    local players = Ryan.Session.ListByBoolean(function(player) return player.is_in_godmode() end)
    
    if #players > 0 then
        Ryan.SendChatMessage("Players likely in godmode: " .. Ryan.Session.ListNames(players) .. ".")
        return
    end
    
    Ryan.SendChatMessage("No players are in godmode.")
end

Ryan.Session.ListByOffRadar = function()
    local players = Ryan.Session.ListByBoolean(function(player) return players.is_otr(player.id) end)
    
    if #players > 0 then
        Ryan.SendChatMessage("Players off-the-radar: " .. Ryan.Session.ListNames(players) .. ".")
        return
    end
    
    Ryan.SendChatMessage("No players are off-the-radar.")
end

Ryan.Session.ListByOnOppressor2 = function()
    local players = Ryan.Session.ListByBoolean(function(player) return player.is_on_oppressor2() end)
    
    if #players > 0 then
        Ryan.SendChatMessage("Players on Oppressors: " .. Ryan.Session.ListNames(players) .. ".")
        return
    end
    
    Ryan.SendChatMessage("No players are on Oppressors.")
end

Ryan.Session.ListNames = function(players)
    local player_names = ""

    for _, player in pairs(players) do
        player_names = player_names .. player.name .. ", "
    end
    if player_names ~= "" then player_names = string.sub(player_names, 1, -3) end

    return player_names
end