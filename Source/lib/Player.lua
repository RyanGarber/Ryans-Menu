Player = {}
Player.__index = Player

_players = {}
--_player_event_queue = {}

players.on_join(function(player_id)
    _players[player_id] = Player:Get(player_id)
    Player:OnJoin(_players[player_id])
end)
players.on_leave(function(player_id)
    Player:OnLeave(_players[player_id])
    _players[player_id] = nil
end)
function Player:Init()
    players.dispatch_on_join()
end


--========================= Static =========================--
-- Get a player by their ID.
function Player:Exists(id)
    return players.exists(id) and _players[id] ~= nil
end

function Player:Get(id, silent)
    if not players.exists(id) then
        if not silent then Ryan.Toast("Tried to get a player that doesn't exist!", debug.getinfo(2).name) end
        return nil
    end

    if _players[id] ~= nil then
        _players[id]:update()
        return _players[id]
    end
    
    local player = {id = id, name = "", ped_id = -1, coords = v3(0, 0, 0), last_update = -1}
    setmetatable(player, self)
    player:update()
    return player
end


-- Get our own player.
function Player:Self()
    return Player:Get(players.user())
end

-- Get a player by its ped ID.
function Player:ByPedId(ped_id)
    for _, player in pairs(Player:List(true, true, true)) do
        if player.ped_id == ped_id then
            return player
        end
    end
    return nil
end

-- Get a player by the start of its name, or a substring.
function Player:ByName(name)
    local fallback_player = nil
    for _, player in pairs(Player:List(true, true, true)) do
        if player.name:lower() == name:lower() then return player end
        local substring_index = player.name:lower():find(name:lower())
        if substring_index == 1 then return player
        elseif substring_index ~= nil then fallback_player = player end
    end
    return fallback_player
end

-- List all players in the session.
function Player:List(include_self, include_friends, include_modders)
    local player_list = {}
    for _, player in pairs(_players) do
        if (include_self or player.id ~= players.user())
        and (include_friends or not player:is_a_friend())
        and (include_modders or not player:is_a_modder()) then
            table.insert(player_list, player)
        end
    end
    return player_list
end

-- List by get_value in descending order.
function Player:ListByNumberDescending(get_value)
    local player_list = Player:List(true, true, true)
    table.sort(player_list, function(player_1, player_2)
        return get_value(player_1) > get_value(player_2)
    end)
    return player_list
end

-- List by get_value being true.
function Player:ListByBoolean(get_value)
    local player_list = {}
    for _, player in pairs(Player:List(true, true, true)) do
        if get_value(player) then
            table.insert(player_list, player)
        end
    end
    return player_list
end

-- Get a comma-separated list of names.
function Player:ListNames(player_list)
    local player_names = ""
    for _, player in pairs(player_list) do player_names = player_names .. player.name .. ", " end
    if player_names:len() > 0 then player_names = string.sub(player_names, 1, -3) end
    return player_names
end


--========================= Instance =========================--
-- Update the player object.
function Player.update(self)
    if util.current_time_millis() - self.last_update > 0 then
        self.name = players.get_name(self.id)
        self.ped_id = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(self.id)
        self.coords = ENTITY.GET_ENTITY_COORDS(self.ped_id)
        self.last_update = util.current_time_millis()
    end
end

-- Get whether the player is detected as a modder.
function Player.is_a_modder(self)
    return players.is_marked_as_modder(self.id)
end

-- Get whether the player is a friend of the user.
function Player.is_a_friend(self)
    return players.get_tags_string(self.id):find("F") or Ryan.FindItemInTable(Ryan.FriendSpoofs, tostring(players.get_rockstar_id(self.id))) ~= nil
end

-- Kick a player using Stand's Smart kick, using Breakup if that fails.
function Player.kick(self)
    menu.trigger_commands("hostkick" .. self.name)
    for i = 1, 10 do
        util.yield(100)
        if Player:ByName(self.name) == nil then break end
        menu.trigger_commands((if menu.get_edition() >= 2 then "breakup" else "kick") .. self.name)
    end
end

-- Crash a player using both of Stand's crashes.
function Player.crash(self)
    Ryan.Toast("Crashing a player...")
    menu.trigger_commands("footlettuce" .. self.name)
    util.yield(250)
    menu.trigger_commands("ngcrash" .. self.name)
end

-- Crash a player using a bugged parachute model.
function Player.super_crash(self, block_syncs)
    Ryan.Toast("Crashing a player...")
    local bush = util.joaat("h4_prop_bush_mang_ad")
    local user = Player:Self()

    local crash = function()
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Super Crash", "Please wait...")
        Ryan.OpenThirdEye(self.coords)

        for attempt = 1, 2 do
            local coords = Ryan.GetClosestNode(self.coords, attempt == 1)
            ENTITY.SET_ENTITY_COORDS(user.ped_id, coords.x, coords.y, coords.z, false, false, false)
            if attempt == 1 then util.yield(500) end
            
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user.id, bush)
            PED.SET_PED_COMPONENT_VARIATION(user.ped_id, 5, 8, 0, 0)
            util.yield(500)

            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user.id)
            if attempt == 1 then util.yield(500)
            else util.yield(2000) end
        end

        for i = 1, 5 do util.spoof_script("freemode", SYSTEM.WAIT) end

        local starting_coords = Ryan.CloseThirdEye()
        ENTITY.SET_ENTITY_HEALTH(user.ped_id, 0)
        NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(starting_coords.x, starting_coords.y, starting_coords.z, 0, false, false, 0)

        Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Super Crash", "Done!")
    end

    if block_syncs then self:do_with_exclusive_syncs(crash)
    else crash() end
end

-- Perform an action while blocking syncs to other players.
function Player.do_with_exclusive_syncs(self, action)
    for _, player in pairs(Player:List(false, true, true)) do
        if player.id ~= self.id then player:block_syncs(true) end
    end
    util.yield(10)
    action()
    for _, player in pairs(Player:List(false, true, true)) do
        if player.id ~= self.id then player:block_syncs(false) end
    end
end

-- Block syncs to this player.
function Player.block_syncs(self, block)
    Ryan.Toast((if block then "Blocked" else "Unblocked") .. " syncs with a player.")
    local outgoing_syncs = menu.ref_by_rel_path(menu.player_root(self.id), "Outgoing Syncs>Block")
    menu.trigger_command(outgoing_syncs, if block then "on" else "off")
end

-- Get the seat the player is in.
function Player.get_vehicle(self)
    local vehicle_model = players.get_vehicle_model(self.id)
    if vehicle_model ~= 0 then
        return PED.GET_VEHICLE_PED_IS_IN(self.ped_id, true)
    end
    return nil
end

-- Get the seat the player is in.
function Player.get_vehicle_seat(self)
    local vehicle_model = players.get_vehicle_model(self.id)
    if vehicle_model ~= 0 then
        local vehicle_id = PED.GET_VEHICLE_PED_IS_IN(self.ped_id, true)
        local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vehicle_model)
        for seat = -1, seats - 2 do
            if VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle_id, seat) == self.ped_id then return seat end
        end
    end
    return nil
end

-- Get whether a player is likely in godmode.
function Player.is_in_godmode(self)
    return not players.is_in_interior(self.id) and players.is_godmode(self.id)
end

-- Get whether a player is on an Oppressor Mk II.
function Player.is_on_oppressor2(self)
    return players.get_vehicle_model(self.id) == util.joaat("oppressor2")
end

-- Teleport a player's vehicle.
function Player.teleport_vehicle(self, coords)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(self.ped_id, true)
    if vehicle ~= 0 then
        Objects.RequestControl(vehicle, true)
        for i = 1, 3 do
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(vehicle, coords.x, coords.y, coords.z, false, false, false)
        end
    end
end

-- Explode a player with or without Bed Sound.
function Player.explode(self, with_earrape)
    local coords = ENTITY.GET_ENTITY_COORDS(self.ped_id)
    FIRE.ADD_EXPLOSION(
        coords.x, coords.y, coords.z,
        59, 100, true, false, 150, false
    )
    if with_earrape then
        Ryan.PlaySoundAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
        coords.z = 2000.0
        Ryan.PlaySoundAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
        coords.z = -2000.0
        Ryan.PlaySoundAtCoords(coords, "WastedSounds", "MP_Flash", 999999999)
    end
end

-- Kill a player in godmode using dark magic.
function Player.squish(self)
    Ryan.Toast("Attempting to kill " .. self.name .. "...")

    local coords = ENTITY.GET_ENTITY_COORDS(self.id)
    local distance = if TASK.IS_PED_STILL(self.ped_id) then 0 else 3
    local vehicle = {["name"] = "Khanjali", ["height"] = 2.8, ["offset"] = 0}  -- {["name"] = "APC", ["height"] = 3.4, ["offset"] = -1.5}
    local vehicle_hash = util.joaat(vehicle.name)

    Ryan.RequestModel(vehicle_hash)    
    local vehicles = {
        -- TODO: use v3
        entities.create_vehicle(vehicle_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(self.ped_id, vehicle.offset, distance, vehicle.height), ENTITY.GET_ENTITY_HEADING(self.ped_id)),
        entities.create_vehicle(vehicle_hash, coords, 0),
        entities.create_vehicle(vehicle_hash, coords, 0),
        entities.create_vehicle(vehicle_hash, coords, 0)
    }
    for i = 1, #vehicles do Objects.RequestControl(vehicles[i]) end  
    
    ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicles[2], vehicles[1], 0, 0, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicles[3], vehicles[1], 0, 3, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicles[4], vehicles[1], 0, 3, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.SET_ENTITY_VISIBLE(vehicles[1], false)

    util.yield(7500)
    for i = 1, #vehicles do entities.delete_by_handle(vehicles[i]) end
    Ryan.FreeModel(vehicle_hash)    
end

-- Send an SMS to a player.
function Player.send_sms(self, message)
    menu.trigger_commands("smstext" .. self.name .. " " .. message)
    menu.trigger_commands("smssend" .. self.name)
end

-- Spam SMS on a player.
function Player.spam_sms(self, message, duration)
    local start_time = util.current_time_millis()
    util.create_thread(function()
        while util.current_time_millis() - start_time < duration do
            self:send_sms(message)
            util.yield()
        end
    end)
end

-- Spam SMS and block joins from a player, then perform a method. 
function Player.spam_sms_and_block_joins(self, block_joins, message, action)
    if block_joins then menu.trigger_commands("historyblock" .. self.name) end
    if message ~= "" and message ~= " " then
        Ryan.Toast("Spamming " .. self.name .. " with texts...")
        self:spam_sms(message, 6000)
    end
    action()
    menu.trigger_commands("players")
end

-- Send a script event to a player.
function Player.send_script_event(self, args, name)
    if name ~= nil then Ryan.Toast("Sending script event: " .. name .. "...") end
    util.trigger_script_event(1 << self.id, args)
    util.yield(10)
end

-- Remove godmode via Force Camera Forward.
function Player.remove_godmode(self)
    self:send_script_event({-1388926377, self.id, -1762807505, math.random(0, 9999)}, "remove godmode")
end

-- Drop a fake money bag on the player.
function Player.drop_fake_money(self)
    local coords = ENTITY.GET_ENTITY_COORDS(self.ped_id); coords:add(v3(0, 0, 2))
    local bag = entities.create_object(2628187989, coords)
    ENTITY.APPLY_FORCE_TO_ENTITY(bag, 3, 0, 0, -20, 0.0, 0.0, 0.0, true, true)
    
    util.yield(333)
    menu.trigger_commands("notifybanked" .. self.name .. " " .. math.random(100, 5000))
    AUDIO.PLAY_SOUND_FROM_COORD(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", coords.x, coords.y, coords.z, "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 2, false)
    entities.delete_by_handle(bag)
end