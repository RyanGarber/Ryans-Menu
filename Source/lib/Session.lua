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
        
        for _, player_id in pairs(players.list()) do
            Ryan.Player.Explode(player_id, with_earrape)
        end
    end,

    SpamChat = function(message, as_other_players, time_between, wait_for)
        local sent = 0
        while sent < 32 do
            if as_other_players then
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
    end,

    -- Sorting Types --
    ListHighestAndLowest = function(get_value)
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
    end,

    ListByBoolean = function(get_value)
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
    end,

    -- Sorting Modes --
    ListByMoney = function()
        data = Ryan.Session.ListHighestAndLowest(Ryan.Player.GetMoney)
    
        message = ""
        if data[1] ~= -1 then
            message = PLAYER.GET_PLAYER_NAME(data[1]) .. " is the richest player here ($" .. Ryan.Basics.FormatNumber(data[2]) .. ")."
        end
        if data[1] ~= data[3] then
            message = message .. " " .. PLAYER.GET_PLAYER_NAME(data[3]) .. " is the poorest ($" .. Ryan.Basics.FormatNumber(data[4]) .. ")."
        end
        if message ~= "" then
            chat.send_message(message, false, true, true)
            return
        end
    end,

    ListByKD = function()
        data = Ryan.Session.ListHighestAndLowest(players.get_kd)
    
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
    end,

    ListByInGodmode = function()
        local player_names = Ryan.Session.ListByBoolean(Ryan.Player.IsInGodmode)
        if player_names ~= "" then
            chat.send_message("Players likely in godmode: " .. player_names .. ".", false, true, true)
            return
        end
        chat.send_message("No players are in godmode.", false, true, true)
    end,

    ListByOffRadar = function()
        local player_names = Ryan.Session.ListByBoolean(Ryan.Player.IsOffRadar)
        if player_names ~= "" then
            chat.send_message("Players off-the-radar: " .. player_names .. ".", false, true, true)
            return
        end
        chat.send_message("No players are off-the-radar.", false, true, true)
    end,

    ListByOnOppressor2 = function()
        local player_names = Ryan.Session.ListByBoolean(Ryan.Player.IsOnOppressor2)
        if player_names ~= "" then
            chat.send_message("Players on Oppressors: " .. player_names .. ".", false, true, true)
            return
        end
        chat.send_message("No players are on Oppressors.", false, true, true)
    end,

    WatchVehicleTakeover = function(player_id, action, wait_for)
        local player_name = players.get_name(player_id)
        menu.trigger_commands("tpveh" .. player_name)
        util.yield(750)

        local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(player_id), false)
        if vehicle ~= 0 then
            Ryan.Entity.RequestControlLoop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                action(vehicle)
                util.yield(wait_for)
            end
        end
    end,

    -- Mass Trolling --
    MassTrollingInProgress = false,

    CancelMassTrolling = function()
        if Ryan.Session.MassTrollingInProgress then
            Ryan.Session.MassTrollingInProgress = false
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Session Trolling", "The mass troll has been cancelled, and will end after this player.")
        else
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Session Trolling", "There is no mass troll to cancel.")
        end
    end,

    WatchMassVehicleTakeover = function(action, include_modders, wait_for)
        if Ryan.Session.MassTrollingInProgress then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Session Trolling", "Mass trolling is already in progress. Wait for it to end or stop it.")
            return
        end
    
        Ryan.Session.MassTrollingInProgress = true
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Session Trolling", "Mass trolling has begun. Sit tight and enjoy the show!")
    
        menu.trigger_commands("otr on")
        menu.trigger_commands("invisibility on")
        
        local starting_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(), true)
        for _, player_id in pairs(players.list()) do
            if not Ryan.Session.MassTrollingInProgress then break end
            if player_id ~= players.user() and not players.is_in_interior(player_id) then
                if include_modders or not players.is_marked_as_modder(player_id) then
                    Ryan.Session.WatchVehicleTakeover(player_id, action, wait_for)
                end
            end
        end
        Ryan.Player.Teleport(starting_coords)
    
        menu.trigger_commands("otr off")
        menu.trigger_commands("invisibility off")
    
        Ryan.Session.MassTrollingInProgress = false
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Session Trolling", "Mass trolling has finished trying all players.")
    end,

    WatchMassCommands = function(commands, include_modders, wait_for)
        if Ryan.Session.MassTrollingInProgress then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Session Trolling", "Mass trolling is already in progress. Wait for it to end or stop it.")
            return
        end
    
        Ryan.Session.MassTrollingInProgress = true
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
        
        menu.trigger_commands("otr on")
        menu.trigger_commands("invisibility on")
        menu.trigger_commands("levitation on")
    
        local starting_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(), true)
        for _, player_id in pairs(players.list()) do
            if not Ryan.Session.MassTrollingInProgress then break end
            if player_id ~= players.user() and not players.is_in_interior(player_id) then
                if include_modders or not players.is_marked_as_modder(player_id) then
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
        Ryan.Player.Teleport(starting_coords)
    
        menu.trigger_commands("otr off")
        menu.trigger_commands("invisibility off")
        menu.trigger_commands("levitation off")
    
        Ryan.Session.MassTrollingInProgress = false
    end,

    WatchMassAction = function(action, include_modders, wait_for)
        if Ryan.Session.MassTrollingInProgress then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Session Trolling", "Mass trolling is already in progress. Wait for it to end or stop it.")
            return
        end
    
        Ryan.Session.MassTrollingInProgress = true
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
        
        menu.trigger_commands("otr on")
        menu.trigger_commands("invisibility on")
        menu.trigger_commands("levitation on")
    
        local starting_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(), true)
        for _, player_id in pairs(players.list()) do
            if not Ryan.Session.MassTrollingInProgress then break end
            if player_id ~= players.user() and not players.is_in_interior(player_id) then
                if include_modders or not players.is_marked_as_modder(player_id) then
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
        Ryan.Player.Teleport(starting_coords)
    
        menu.trigger_commands("otr off")
        menu.trigger_commands("invisibility off")
        menu.trigger_commands("levitation off")
    
        Ryan.Session.MassTrollingInProgress = false
    end
}