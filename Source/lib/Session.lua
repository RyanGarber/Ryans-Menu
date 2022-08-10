Ryan.Session = {
    ExplodeAll = function(with_earrape)
        if with_earrape then -- Credit: Bed Sound
            for _, coords in pairs(Ryan.Globals.BedSoundCoords) do
                Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "Bed", 999999999)
                coords.z = 2000.0
                Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "Bed", 999999999)
                coords.z = -2000.0
                Ryan.Audio.PlayAtCoords(coords, "WastedSounds", "Bed", 999999999)
            end
        end
        
        for _, player in pairs(Ryan.Player.List(true, true, true)) do
            player.explode(with_earrape)
        end
    end,

    SpamChat = function(message, delay)
        local sent = 0
        while sent < 32 do
            Ryan.Basics.SendChatMessage(message)
            util.yield(delay)
            sent = sent + 1
        end
        util.yield(wait_for)
    end,

    -- Sorting Types --
    ListHighestAndLowest = function(get_value)
        local highest_amount = 0
        local highest_player = nil
        local lowest_amount = 2147483647
        local lowest_player = nil
    
        for _, player_id in pairs(players.list()) do
            local player = Ryan.Player.ById(player_id)
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
    end,

    ListByBoolean = function(get_value)
        local players = {}

        for _, player in pairs(Ryan.Player.List(true, true, true)) do
            if get_value(player) then
                table.insert(players, player)
            end
        end

        return players
    end,

    -- Sorting Modes --
    ListByMoney = function()
        local data = Ryan.Session.ListHighestAndLowest(function(player) return players.get_money(player.id) end)

        message = ""
        if data[1] ~= -1 then
            message = data.highest.player.name .. " is the richest player here ($" .. Ryan.Basics.FormatNumber(data.highest.amount) .. ")."
        end
        if data[1] ~= data[3] then
            message = message .. " " .. data.lowest.player.name .. " is the poorest ($" .. Ryan.Basics.FormatNumber(data.lowest.amount) .. ")."
        end

        if message ~= "" then
            Ryan.Basics.SendChatMessage(message)
            return
        end
    end,

    ListByKD = function()
        data = Ryan.Session.ListHighestAndLowest(function(player) return players.get_kd(player.id) end)
        message = ""
    
        if data[1] ~= -1 then
            message = data.highest.player.name .. " has the highest K/D here (" .. string.format("%.1f", data.highest.amount) .. ")."
        end
        if data[1] ~= data[3] then
            message = message .. " " .. data.lowest.player.name .. " has the lowest (" .. string.format("%.1f", data.lowest.amount) .. ")."
        end
       
        if message ~= "" then
            Ryan.Basics.SendChatMessage(message)
            return
        end
    end,

    ListByInGodmode = function()
        local players = Ryan.Session.ListByBoolean(function(player) return player.is_in_godmode() end)
       
        if #players > 0 then
            Ryan.Basics.SendChatMessage("Players likely in godmode: " .. Ryan.Session.ListNames(players) .. ".")
            return
        end
        
        Ryan.Basics.SendChatMessage("No players are in godmode.")
    end,

    ListByOffRadar = function()
        local players = Ryan.Session.ListByBoolean(function(player) return players.is_otr(player.id) end)
        
        if #players > 0 then
            Ryan.Basics.SendChatMessage("Players off-the-radar: " .. Ryan.Session.ListNames(players) .. ".")
            return
        end
        
        Ryan.Basics.SendChatMessage("No players are off-the-radar.")
    end,

    ListByOnOppressor2 = function()
        local players = Ryan.Session.ListByBoolean(function(player) return player.is_on_oppressor2() end)
        
        if #players > 0 then
            Ryan.Basics.SendChatMessage("Players on Oppressors: " .. Ryan.Session.ListNames(players) .. ".")
            return
        end
        
        Ryan.Basics.SendChatMessage("No players are on Oppressors.")
    end,

    ListNames = function(players)
        local player_names = ""

        for _, player in pairs(players) do
            player_names = player_names .. player.name .. ", "
        end
        if player_names ~= "" then player_names = string.sub(player_names, 1, -3) end

        return player_names
    end
}