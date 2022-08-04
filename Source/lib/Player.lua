Ryan.Player = {
    GetPed = function(player_id)
        if not player_id then return players.user_ped() end
        return PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
    end,

    GetMoney = function(player_id)
        return players.get_wallet(player_id) + players.get_bank(player_id)
    end,

    IsOffRadar = function(player_id)
        return players.is_otr(player_id)
    end,

    IsInGodmode = function(player_id)
        return not players.is_in_interior(player_id) and players.is_godmode(player_id)
    end,

    IsOnOppressor2 = function(player_id)
        return players.get_vehicle_model(player_id) == util.joaat("oppressor2")
    end,

    Teleport = function(coords)
        util.toast("Teleporting...")
        ENTITY.SET_ENTITY_COORDS(Ryan.Player.GetPed(), coords.x, coords.y, coords.z)
    end,

    TeleportWithVehicle = function(coords)
        util.toast("Teleporting...")
        local player_ped = Ryan.Player.GetPed()
        if PED.IS_PED_IN_ANY_VEHICLE(player_ped, true) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
            ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z)
        else
            ENTITY.SET_ENTITY_COORDS(player_ped, coords.x, coords.y, coords.z)
        end
    end,

    TeleportVehicle = function(player_id, coords)
        local name = PLAYER.GET_PLAYER_NAME(player_id)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id), true)
        if vehicle ~= 0 then
            Ryan.Entity.RequestControlLoop(vehicle)
            for i = 1, 3 do
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(vehicle, coords.x, coords.y, coords.z, false, false, false)
            end
        end
    end,

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

    RemoveGodmode = function(player_id, vehicle_too)
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
    end,

    SpamTextsAndBlockJoins = function(player_id, removal_block_joins, removal_message, action)
        local player_name = players.get_name(player_id)
        if removal_block_joins then
            Ryan.Player.BlockJoins(player_name)
        end
        if removal_message ~= "" and removal_message ~= " " then
            util.toast("Spamming " .. player_name .. " with texts...")
            Ryan.Player.SpamTexts(player_id, removal_message, 6000)
        end
        action()
        menu.trigger_commands("players")
    end,

    SpamTexts = function(player_id, message, duration)
        local player_name = players.get_name(player_id)
        menu.trigger_commands("smsrandomsender" .. player_name .. " on")
        menu.trigger_commands("smstext" .. player_name .. " " .. message)
        menu.trigger_commands("smsspam" .. player_name .. " on")
        util.yield(duration)
        menu.trigger_commands("smsspam" .. player_name .. " off")
    end,

    BlockJoins = function(player_name)
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
    end,

    SendScriptEvent = function(player_id, args, name)
        util.toast("Sending script event: " .. name .. "...")
        util.trigger_script_event(1 << player_id, args)
        util.yield(10)
    end,

    CrashToSingleplayer = function(player_id)
        if player_id == players.user() then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Crash To Singleplayer", "I don't need to explain why what you just tried to do was not very smart, do I?")
            return
        end
    
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Crash To Singleplayer", "Now sending script events. This may take a while...")
        local events = Ryan.Basics.ShuffleItemsInTable(Ryan.Globals.CrashToSingleplayerEvents)
        for _, event in pairs(events) do
            Ryan.Player.SendScriptEvent(player_id, event, "Crash To Singleplayer")
        end
    end,

    CrashToDesktop = function(player_id, mode, safely)
        if player_id == players.user() then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Crash To Desktop", "I don't need to explain why what you just tried to do was not very smart, do I?")
            return
        end

        local starting_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
        local in_danger_zone = Ryan.Vector.Distance(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id)), starting_coords) < Ryan.Globals.SafeCrashDistance

        if safely and in_danger_zone then
            Ryan.Player.Teleport(Ryan.Globals.SafeCrashCoords)
            util.yield(1000)
        end
    
        if not mode then
            for _, crash_mode in pairs(Ryan.Globals.CrashToDesktopMethods) do
                util.create_thread(function()
                    Ryan.Player.CrashToDesktop(player_id, crash_mode, false)
                end)
            end
            if safely and in_danger_zone then
                util.yield(Ryan.Globals.SafeCrashDuration)
                Ryan.Player.Teleport(starting_coords)
            end
            return
        end
    
        local player_ped = Ryan.Player.GetPed(player_id)
        local player_ped_heading = ENTITY.GET_ENTITY_HEADING(player_ped)
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Crash To Desktop", "Now spawning entities. This may take a while...")
        for _, crash_mode in pairs(Ryan.Globals.CrashToDesktopMethods) do
            if mode == crash_mode then util.toast("Beginning crash: " .. crash_mode .. " on " .. players.get_name(player_id) .. ".") end
        end
    
        if mode == "Yo Momma" then
            local fatcult = util.joaat("a_f_m_fatcult_01"); Ryan.Basics.RequestModel(fatcult)
            for i = 1, 8 do
                util.create_thread(function()
                    local ped = entities.create_ped(
                        0, fatcult,
                        Ryan.Vector.Add(player_coords, {x = math.random(-1, 1), y = math.random(-1, 1), z = 0}),
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
                Ryan.Player.SendScriptEvent(player_id, {962740265, player_id, 23243, 5332, 3324, player_id}, "final payload")
            end
        end
    
        if mode == "Vegetation" then
            Ryan.Basics.RequestModel(-930879665)
            Ryan.Basics.RequestModel(3613262246)
            Ryan.Basics.RequestModel(452618762)
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
            local hashes = Ryan.Basics.ShuffleItemsInTable(Ryan.Globals.InvalidObjects)
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

        if safely and in_danger_zone then
            util.yield(Ryan.Globals.SafeCrashDuration)
            Ryan.Player.Teleport(starting_coords)
        end
    end
}