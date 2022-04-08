VERSION = "0.6.0"
MANIFEST = {
    lib = {"Audio.lua", "Entity.lua", "Globals.lua", "Player.lua", "PTFX.lua", "Vector.lua", "Vehicle.lua"},
    resources = {"Crosshair.png"}
}


-- Requirements --
function exists(name)
    return filesystem.exists(filesystem.scripts_dir() .. name)
end

notified_of_requirements = false
while not exists("lib\\natives-1640181023.lua") or not exists("lib\\natives-1627063482.lua") do
    if not notified_of_requirements then
        local ref = menu.ref_by_path("Stand>Lua Scripts>Repository>WiriScript")
        menu.focus(ref)
        notified_of_requirements = true
    end

    util.toast("Ryan's Menu requires WiriScript and LanceScript to function. Please enable them to continue.")
    util.yield(2000)
end
require("natives-1640181023")

for required_directory, required_files in pairs(MANIFEST) do
    for _, required_file in pairs(required_files) do
        while not exists(required_directory .. "\\Ryan's Menu\\" .. required_file) do
            util.toast("Ryan's Menu is missing a required file (" .. required_file .. ") and must be reinstalled.")
            util.yield(2000)
        end
        if required_directory == 'lib' then
            require(required_directory .. "\\Ryan's Menu\\" .. required_file:sub(0, -5))
        end
    end
end


-- Check for Updates --
async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/MANIFEST", function(manifest)
    latest_version = manifest:sub(1, manifest:find("\n") - 1)
    if latest_version ~= VERSION then
        show_text_message(Colors.Red, "v" .. VERSION, "This version is outdated. Press Get Latest Version to get v" .. latest_version .. ".")
        menu.trigger_commands("ryansettings")
    else
        show_text_message(Colors.Purple, "v" .. VERSION, "You're up to date. Enjoy!")
    end
    audio_play_from_entity(player_get_ped(), "GTAO_FM_Events_Soundset", "Object_Dropped_Remote")
end, function()
    show_text_message(Colors.Red, "v" .. VERSION, "Failed to get the latest version. Go to Settings to check manually.")
end)
async_http.dispatch()


-- Basic Functions --
function teleport_to(x, y, z)
    util.toast("Teleporting...")
    ENTITY.SET_ENTITY_COORDS(player_get_ped(), x, y, z)
end

function teleport_with_vehicle_to(x, y, z)
    util.toast("Teleporting...")
    local player_ped = player_get_ped()
    if PED.IS_PED_IN_ANY_VEHICLE(player_ped, true) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
        ENTITY.SET_ENTITY_COORDS(vehicle, x, y, z)
    else
        ENTITY.SET_ENTITY_COORDS(player_ped, x, y, z)
    end
end

function get_random(table) -- Credit: WiriScript
	if rawget(table, 1) ~= nil then return table[math.random(1, #table)] end
	local list = {}
	for _, value in pairs(table) do table.insert(list, value) end
	return list[math.random(1, #list)]
end

function format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function request_model(model)
    if STREAMING.IS_MODEL_VALID(model) then
        STREAMING.REQUEST_MODEL(model)
        while not STREAMING.HAS_MODEL_LOADED(model) do
            util.yield()
        end
    else
        util.toast("Invalid model '" .. model .."', please report this issue to Ryan.")
    end
end

function request_animations(animation_group)
    STREAMING.REQUEST_ANIM_DICT(animation_group)
    while not STREAMING.HAS_ANIM_DICT_LOADED(animation_group) do
        util.yield()
    end
end

function show_text_message(color, subtitle, message)
    HUD._THEFEED_SET_NEXT_POST_BACKGROUND_COLOR(color)
	GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("DIA_JESUS", 0)
	while not GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED("DIA_JESUS") do
		util.yield()
	end
	util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
	HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT("DIA_JESUS", "DIA_JESUS", true, 4, "Ryan's Menu", subtitle)
	HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(true, false)
end

function do_raycast(distance) -- Credit: WiriScript
    local result = {}
	local did_hit = memory.alloc(8)
	local hit_coords = v3.new()
	local hit_normal = v3.new()
	local hit_entity = memory.alloc_int()
	local origin = CAM.GET_FINAL_RENDERED_CAM_COORD()
	local destination = vector_offset_from_camera(distance)

	SHAPETEST.GET_SHAPE_TEST_RESULT(
		SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
			origin.x, origin.y, origin.z,
			destination.x, destination.y, destination.z,
			-1, PLAYER.PLAYER_PED_ID(), 1
		), did_hit, hit_coords, hit_normal, hit_entity
	)
	result.did_hit = memory.read_byte(did_hit) ~= 0
	result.hit_coords = v3_to_object(v3.get(hit_coords))
	result.hit_normal = v3_to_object(v3.get(hit_normal))
	result.hit_entity = memory.read_int(hit_entity)

	memory.free(did_hit)
	v3.free(hit_coords)
	v3.free(hit_normal)
	memory.free(hit_entity)
	return result
end


-- Stats --
function set_office_money(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 crate of Special Cargo to sell before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell that cargo.", function()
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_COMPLETE"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_SELL_COMPLETE"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_UNDERTAKEN"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_UNDERTAKEN"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_CONTRA_EARNINGS"), amount, true)

        show_text_message(Colors.Purple, "CEO Office Money", "Done! Switch sessions and start a Special Cargo sale to apply your changes.")
    end)
end

function set_mc_clutter(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 unit of stock to sell, in every business, before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell all of those, one by one.", function()
        for i=0, 5 do
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS" .. i), amount, true)
            if i == 0 then i = "" end
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_BUY_COMPLET" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_BUY_UNDERTA" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_SELL_COMPLET" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_SELL_UNDERTA" .. i), 1000, true)
        end

        show_text_message(Colors.Purple, "M.C. Clubhouse Clutter", "Done! Switch sessions and start a sale in every business to apply changes.")
    end)
end


-- Player Functions --
function do_sms_spam(player_id, message, duration)
    local player_name = PLAYER.GET_PLAYER_NAME(player_id)
    menu.trigger_commands("smsrandomsender" .. player_name .. " on")
    menu.trigger_commands("smstext" .. player_name .. " " .. message)
    menu.trigger_commands("smsspam" .. player_name .. " on")
    util.yield(duration)
    menu.trigger_commands("smsspam" .. player_name .. " off")
end

function do_fake_money_drop(player_id)
    menu.trigger_commands("notifybanked" .. PLAYER.GET_PLAYER_NAME(player_id) .. " " .. math.random(100, 5000))
    local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id))
    local bag = entities.create_object(2628187989, vector_add(coords, {x = 0, y = 0, z = 2}))
    ENTITY.APPLY_FORCE_TO_ENTITY(bag, 3, 0, 0, -15, 0.0, 0.0, 0.0, true, true)
    util.yield(250)
    AUDIO.PLAY_SOUND_FROM_COORD(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", coords.x, coords.y, coords.z, "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 2, false)
    entities.delete_by_handle(bag)
end

function do_trash_pickup(player_id)
    util.toast("Sending the trash man to " .. PLAYER.GET_PLAYER_NAME(player_id) .. "...")

    local player_ped = player_get_ped(player_id)
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)

    local trash_truck = util.joaat("trash"); request_model(trash_truck)
    local trash_man = util.joaat("s_m_y_garbage"); request_model(trash_man)

    local weapons = {"weapon_pistol", "weapon_pumpshotgun"}
    local coords_ptr = memory.alloc()
    local node_ptr = memory.alloc()
    
    if not PATHFIND.GET_RANDOM_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, 80, 0, 0, 0, coords_ptr, node_ptr) then
        player_coords.x = player_coords.x + math.random(-7, 7)
        player_coords.y = player_coords.y + math.random(-7, 7)
        PATHFIND.GET_CLOSEST_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, coords_ptr, 1, 100, 2.5)
    end

    local coords = memory.read_vector3(coords_ptr); memory.free(coords_ptr); memory.free(node_ptr)
    local vehicle = entities.create_vehicle(trash_truck, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    entity_face_entity(vehicle, player_ped)
    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)

    for seat = -1, 2 do
        local npc = entities.create_ped(5, trash_man, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        local weapon = get_random(weapons)

        PED.SET_PED_RANDOM_COMPONENT_VARIATION(npc, 0)
        WEAPON.GIVE_WEAPON_TO_PED(npc, util.joaat(weapon) , -1, false, true)
        PED.SET_PED_NEVER_LEAVES_GROUP(npc, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 1, true)
        PED.SET_PED_INTO_VEHICLE(npc, vehicle, seat)
        ENTITY.SET_ENTITY_INVINCIBLE(npc, false)
        TASK.TASK_COMBAT_PED(npc, player_ped, 0, 16)
        PED.SET_PED_KEEP_TASK(npc, true)

        util.create_tick_handler(function()
            if TASK.GET_SCRIPT_TASK_STATUS(npc, 0x2E85A751) == 7 then
                TASK.CLEAR_PED_TASKS(npc)
                TASK.TASK_SMART_FLEE_PED(npc, player_get_ped(player_id), 1000.0, -1, false, false)
                PED.SET_PED_KEEP_TASK(npc, true)
                return false
            end
            return true
        end)
    end
    
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(trash_truck)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(trash_man)

    do_sms_spam(player_id, "It's trash day! Time to take it out.", 5000)
end

function watch_and_takeover_vehicle(action, player_id, wait_for)
    local player_name = PLAYER.GET_PLAYER_NAME(player_id)
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

function do_omnicrash(player_id)
    show_text_message(Colors.Purple, "Omnicrash Mk II", "Omnicrash has begun. This may take a while...")
    for _, crash_event in pairs(CrashEvents) do
        player_send_script_event(player_id, crash_event, "Omnicrash")
    end
end


-- Session Functions --
function watch_and_takeover_vehicle_all(action, modders, wait_for)
    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(), true)
    show_text_message(Colors.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    for _, player_id in pairs(players.list()) do
        if player_id ~= players.user() and not players.is_in_interior(player_id) then
            if modders or not players.is_marked_as_modder(player_id) then
                watch_and_takeover_vehicle(action, player_id, wait_for)
            end
        end
    end
    teleport_to(starting_coords.x, starting_coords.y, starting_coords.z)
    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
end

function watch_and_trigger_command_all(commands, modders, wait_for)
    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped(), true)
    show_text_message(Colors.Purple, "Session Trolling", "Session trolling has begun. Sit tight and enjoy the show!")
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    menu.trigger_commands("levitation on")
    for _, player_id in pairs(players.list()) do
        if player_id ~= players.user() and not players.is_in_interior(player_id) then
            if modders or not players.is_marked_as_modder(player_id) then
                local player_name = PLAYER.GET_PLAYER_NAME(player_id)
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
    teleport_to(starting_coords.x, starting_coords.y, starting_coords.z)
    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
    menu.trigger_commands("levitation off")
end

function spam_chat(message, all_players, time_between, wait_for)
    local sent = 0
    while sent < 32 do
        if all_players then
            for _, player_id in pairs(players.list()) do
                local name = PLAYER.GET_PLAYER_NAME(player_id)
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

function send_translated(message, language, latin)
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

function explode_all(with_earrape)
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


-- Main Menu --
world_root = menu.list(menu.my_root(), "World", {"ryanworld"}, "Helpful options for entities in the world.")
session_root = menu.list(menu.my_root(), "Session", {"ryansession"}, "Trolling options for the entire session.")
stats_root = menu.list(menu.my_root(), "Stats", {"ryanstats"}, "Common stats you may want to edit.")
chat_root = menu.list(menu.my_root(), "Chat", {"ryanchat"}, "Send special chat messages.")
settings_root = menu.list(menu.my_root(), "Settings", {"ryansettings"}, "Settings for Ryan's Menu.")


-- World Menu --
world_closest_vehicle_root = menu.list(world_root, "Closest Vehicle...", {"ryanclosestvehicle"}, "Useful options for nearby vehicles.")
world_vehicles_root = menu.list(world_root, "All Vehicles...", {"ryanallvehicles"}, "Control the vehicles around you.")
world_npc_action_root = menu.list(world_root, "All NPCs: None", {"ryannpcaction"}, "Changes the action NPCs are currently performing.")
world_collectibles_root = menu.list(world_root, "Collectibles...", {"ryancollectibles"}, "Useful presets to teleport to.")
world_forcefield_root = menu.list(world_root, "Forcefield...", {"ryanforcefield"}, "An enhanced WiriScript forcefield.")
world_ptfx_root = menu.list(world_root, "PTFX...", {"ryanptfx"}, "Special FX options.")


-- -- Enter Closest Vehicle
menu.action(world_closest_vehicle_root, "Enter", {"ryandrivevehicle"}, "Teleports into the closest vehicle.", function()
    local closest_vehicle = vehicle_get_closest(ENTITY.GET_ENTITY_COORDS(player_get_ped(), true))
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(closest_vehicle, -1)
    
    if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, -1) then
        PED.SET_PED_INTO_VEHICLE(player_get_ped(), closest_vehicle, -1)
        util.toast("Teleported into the closest vehicle.")
    else
        if PED.GET_PED_TYPE(driver) >= 4 then
            entities.delete(driver)
            PED.SET_PED_INTO_VEHICLE(player_get_ped(), closest_vehicle, -1)
            util.toast("Teleported into the closest vehicle.")
        elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(closest_vehicle) then
            for i=0, 10 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, i) then
                    PED.SET_PED_INTO_VEHICLE(player_get_ped(), closest_vehicle, i)
                    break
                end
            end
            util.toast("Teleported into the closest vehicle.")
        else
            util.toast("No nearby vehicles found.")
        end
    end
end)

-- -- Upgrade Closest Vehicle
menu.action(world_closest_vehicle_root, "Upgrade", {"ryanupgradevehicle"}, "Upgrades the closest vehicle.", function()
    local closest_vehicle = vehicle_get_closest(ENTITY.GET_ENTITY_COORDS(player_get_ped(), true))
    entity_request_control_loop(closest_vehicle)
    vehicle_set_upgraded(closest_vehicle, true)
    util.toast("Upgraded the nearest car!")
end)

-- -- Downgrade Closest Vehicle
menu.action(world_closest_vehicle_root, "Downgrade", {"ryandowngradevehicle"}, "Downgrades the closest vehicle.", function()
    local closest_vehicle = vehicle_get_closest(ENTITY.GET_ENTITY_COORDS(player_get_ped(), true))
    entity_request_control_loop(closest_vehicle)
    vehicle_set_upgraded(closest_vehicle, false)
    util.toast("Downgraded the nearest car!")
end)

world_action_figures_root = menu.list(world_collectibles_root, "Action Figures...", {"ryanactionfigures"}, "Every action figure in the game.")
world_signal_jammers_root = menu.list(world_collectibles_root, "Signal Jammers...", {"ryansignaljammers"}, "Every signal jammer in the game.")
world_playing_cards_root = menu.list(world_collectibles_root, "Playing Cards...", {"ryanplayingcards"}, "Every playing card in the game.")

-- -- Make Vehicles Fast
menu.toggle_loop(world_vehicles_root, "Make Fast", {"ryanmakeallfast"}, "Makes all nearby vehicles fast.", function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.Vehicles)
    for _, vehicle in pairs(vehicles) do
        if vehicle ~= player_vehicle then
            vehicle_set_speed(vehicle, true)
        end
    end
    util.yield(250)
end, false)

-- -- Make Vehicles Slow
menu.toggle_loop(world_vehicles_root, "Make Slow", {"ryanmakeallslow"}, "Makes all nearby vehicles slow.", function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.Vehicles)
    for _, vehicle in pairs(vehicles) do
        if vehicle ~= player_vehicle then
            vehicle_set_speed(vehicle, false)
        end
    end
    util.yield(250)
end, false)

-- -- Make Vehicles Drift
menu.toggle_loop(world_vehicles_root, "No Grip", {"ryanmakealldrift"}, "Makes all nearby vehicles lose grip.", function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.Vehicles)
    for _, vehicle in pairs(vehicles) do
        if vehicle ~= player_vehicle then
            vehicle_set_no_grip(vehicle, true)
        end
    end
    util.yield(250)
end, false)

-- -- Lock Vehicle Doors
menu.toggle_loop(world_vehicles_root, "Lock Doors", {"ryanmakealllocked"}, "Locks all nearby vehicles.", function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.Vehicles)
    for _, vehicle in pairs(vehicles) do
        if vehicle ~= player_vehicle then
            vehicle_lock_doors(vehicle, true)
        end
    end
    util.yield(250)
end, false)

-- -- Make Vehicles Burst
vehicles_bursted = {}
menu.toggle_loop(world_vehicles_root, "Burst Tires", {"ryanmakeallburst"}, "Makes all nearby vehicles have sudden tire loss.", function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.Vehicles)
    for _, vehicle in pairs(vehicles) do
        local was_bursted = false
        for _, vehicle_bursted in pairs(vehicles_bursted) do
            if vehicle_bursted == vehicle then was_bursted = true end
        end
        if not was_bursted and vehicle ~= player_vehicle then
            vehicle_burst_tires(vehicle)
            table.insert(vehicles_bursted, vehicle)
        end
    end
    util.yield(250)
end, false)

-- -- Make Vehicles Catapult
menu.toggle_loop(world_vehicles_root, "Catapult", {"ryanmakeallcatapult"}, "Makes all nearby vehicles catapult in the air.", function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.Vehicles)
    for _, vehicle in pairs(vehicles) do
        if vehicle ~= player_vehicle then
            vehicle_catapult(vehicle)
        end
    end
    util.yield(250)
end, false)

-- -- NPC Action
npc_action = nil
menu.action(world_npc_action_root, "None", {"ryannpcnone"}, "Makes NPCs normal.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: None")
    menu.focus(world_npc_action_root)
    npc_action = nil
end)
menu.action(world_npc_action_root, "Musician", {"ryannpcmusician"}, "Makes NPCs into musicians.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: Musician")
    menu.focus(world_npc_action_root)
    npc_action = "WORLD_HUMAN_MUSICIAN"
end)
menu.action(world_npc_action_root, "Human Statue", {"ryannpcstatue"}, "Makes NPCs into human statues.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: Human Statue")
    menu.focus(world_npc_action_root)
    npc_action = "WORLD_HUMAN_HUMAN_STATUE"
end)
menu.action(world_npc_action_root, "Paparazzi", {"ryannpcpaparazzi"}, "Makes NPCs into paparazzi.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: Paparazzi")
    menu.focus(world_npc_action_root)
    npc_action = "WORLD_HUMAN_PAPARAZZI"
end)
menu.action(world_npc_action_root, "Janitor", {"ryannpcjanitor"}, "Makes NPCs into janitors.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: Janitor")
    menu.focus(world_npc_action_root)
    npc_action = "WORLD_HUMAN_JANITOR"
end)

npcs_affected = {}
util.create_tick_handler(function()
    if npc_action ~= nil then
        local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped())
        for _, ped in pairs(entity_get_all_nearby(coords, 200, NearbyEntitiesModes.Peds)) do
            if not PED.IS_PED_A_PLAYER(ped) and not PED.IS_PED_IN_ANY_VEHICLE(ped) then
                local was_affected = false
                for _, npc in pairs(npcs_affected) do
                    if npc == ped then was_affected = true end
                end
                if not was_affected then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(ped, npc_action, 0, true)
                    table.insert(npcs_affected, ped)
                end
            end
        end
    end
    util.yield(250)
end)

-- -- Action Figures
for i = 1, #ActionFigures do
    menu.action(world_action_figures_root, "Action Figure " .. i, {"ryanactionfigure" .. i}, "Teleports to action figure #" .. i, function()
        teleport_to(ActionFigures[i][1], ActionFigures[i][2], ActionFigures[i][3])
    end)
end

-- -- Signal Jammers
for i = 1, #SignalJammers do
    menu.action(world_signal_jammers_root, "Signal Jammer " .. i, {"ryansignaljammer" .. i}, "Teleports to signal jammer #" .. i, function()
        teleport_with_vehicle_to(SignalJammers[i][1], SignalJammers[i][2], SignalJammers[i][3])
    end)
end

-- -- Playing Cards
for i = 1, #PlayingCards do
    menu.action(world_playing_cards_root, "Playing Card " .. i, {"ryanplayingcard" .. i}, "Teleports to playing card #" .. i, function()
        teleport_with_vehicle_to(PlayingCards[i][1], PlayingCards[i][2], PlayingCards[i][3])
    end)
end


-- -- Forcefield
forcefield_mode = ForcefieldModes.None
forcefield_size = 10
forcefield_force = 1

self_forcefield_mode_root = menu.list(world_forcefield_root, "Mode: None", {"ryanforcefieldmode"}, "Forcefield mode.")
for mode_name, mode_id in pairs(ForcefieldModes) do
    menu.action(self_forcefield_mode_root, mode_name, {"ryanforcefield" .. mode_name:lower()}, "", function()
        forcefield_mode = mode_id
        menu.set_menu_name(self_forcefield_mode_root, "Mode: " .. mode_name)
        menu.focus(self_forcefield_mode_root)
    end)
end

menu.divider(world_forcefield_root, "Options")
menu.slider(world_forcefield_root, "Size", {"ryanforcefieldsize"}, "Diameter of the forcefield sphere.", 10, 250, 10, 10, function(value)
    forcefield_size = value
end)
menu.slider(world_forcefield_root, "Force", {"ryanforcefieldforce"}, "Force applied by the forcefield.", 1, 100, 1, 1, function(value)
    forcefield_force = value
end)

entities_destroyed = {}
util.create_tick_handler(function()
    if forcefield_mode == ForcefieldModes.Push then -- Push
        local player_ped = player_get_ped()
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
		local entities = entity_get_all_nearby(player_coords, forcefield_size)
		for _, entity in pairs(entities) do
			local entity_coords = ENTITY.GET_ENTITY_COORDS(entity)
			local force = vector_normalize(vector_subtract(entity_coords, player_coords))
            force = vector_multiply(force, forcefield_force)
			if ENTITY.IS_ENTITY_A_PED(entity)  then
				if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
					entity_request_control(entity)
					PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
					ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
				end
			else
				entity_request_control(entity)
				ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
			end
		end
        entities_destroyed = {}
    elseif forcefield_mode == ForcefieldModes.Destroy then -- Destroy
        local player_ped = player_get_ped()
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

        local entities = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.All)
        for _, entity in pairs(entities) do
            local was_destroyed = false
            for _, destroyed_entity in pairs(entities_destroyed) do
                if destroyed_entity == entity then was_destroyed = true end
            end

            if not was_destroyed then
                if entity ~= player_ped and entity ~= player_vehicle then
                    local coords = ENTITY.GET_ENTITY_COORDS(entity)
                    FIRE.ADD_EXPLOSION(
                        coords.x, coords.y, coords.z,
                        29, 5.0, false, true, 0.0
                    )
                end
                table.insert(entities_destroyed, entity)
            end
        end
    else
        entities_destroyed = {}
    end
    return true
end)

-- -- PTFX
ptfx_color = {r = 1.0, g = 1.0, b = 1.0}

world_ptfx_body_root = menu.list(world_ptfx_root, "Body...", {"ryanptfxbody"}, "Special FX on your body other players can see.")
world_ptfx_weapon_root = menu.list(world_ptfx_root, "Weapon...", {"ryanptfxweapon"}, "Special FX on your weapon other players can see.")
world_ptfx_vehicle_root = menu.list(world_ptfx_root, "Vehicle...", {"ryanptfxvehicle"}, "Special FX on your vehicle other players can see.")
world_ptfx_pointing_root = menu.list(world_ptfx_root, "Pointing...", {"ryanptfxpointing"}, "Special FX when pointing other players can see.")

menu.divider(world_ptfx_root, "Options")
menu.colour(world_ptfx_root, "Color", {"ryanptfxcolor"}, "Some PTFX options allow for custom colors.", 1.0, 1.0, 1.0, 1.0, false, function(color)
    ptfx_color.r = color.r
    ptfx_color.g = color.g
    ptfx_color.b = color.b
end)

-- -- Body PTFX
self_ptfx_body_head_root = menu.list(world_ptfx_body_root, "Head...", {"ryanptfxhead"}, "Special FX on your head.")
self_ptfx_body_hands_root = menu.list(world_ptfx_body_root, "Hands...", {"ryanptfxhands"}, "Special FX on your hands.")
self_ptfx_body_feet_root = menu.list(world_ptfx_body_root, "Feet...", {"ryanptfxfeet"}, "Special FX on your feet.")

ptfx_create_list(self_ptfx_body_head_root, function(ptfx)
    ptfx_play_on_entity_bones(player_get_ped(), PlayerBones.Head, ptfx[1], ptfx[2], ptfx_color)
    util.yield(ptfx[3])
end)

ptfx_create_list(self_ptfx_body_hands_root, function(ptfx)
    ptfx_play_on_entity_bones(player_get_ped(), PlayerBones.Hands, ptfx[1], ptfx[2], ptfx_color)
    util.yield(ptfx[3])
end)

ptfx_create_list(self_ptfx_body_feet_root, function(ptfx)
    ptfx_play_on_entity_bones(player_get_ped(), PlayerBones.Feet, ptfx[1], ptfx[2], ptfx_color)
    util.yield(ptfx[3])
end)

-- -- Vehicle PTFX
self_ptfx_vehicle_wheels_root = menu.list(world_ptfx_vehicle_root, "Wheels...", {"ryanptfxwheels"}, "Special FX on the wheels of your vehicle.")
self_ptfx_vehicle_exhaust_root = menu.list(world_ptfx_vehicle_root, "Exhaust...", {"ryanptfxexhaust"}, "Speicla FX on the exhaust of your vehicle.")

ptfx_create_list(self_ptfx_vehicle_wheels_root, function(ptfx)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(), true)
    if vehicle ~= NULL then
        ptfx_play_on_entity_bones(vehicle, VehicleBones.Wheels, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

ptfx_create_list(self_ptfx_vehicle_exhaust_root, function(ptfx)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(), true)
    if vehicle ~= NULL then
        ptfx_play_on_entity_bones(vehicle, VehicleBones.Exhaust, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

-- -- Weapon PTFX
self_ptfx_weapon_aiming_root = menu.list(world_ptfx_weapon_root, "Aiming...", {"ryanptfxaiming"}, "Special FX when aiming at a spot.")
self_ptfx_weapon_muzzle_root = menu.list(world_ptfx_weapon_root, "Muzzle...", {"ryanptfxmuzzle"}, "Special FX on the end of your weapon's barrel.")
self_ptfx_weapon_muzzle_flash_root = menu.list(world_ptfx_weapon_root, "Muzzle Flash...", {"ryanptfxmuzzleflash"}, "Special FX on the end of your weapon's barrel when firing.")
self_ptfx_weapon_impact_root = menu.list(world_ptfx_weapon_root, "Impact...", {"ryanptfximpact"}, "Special FX at the impact of your bullets.")

ptfx_create_list(self_ptfx_weapon_aiming_root, function(ptfx)
    if CAM.IS_AIM_CAM_ACTIVE() then
        local raycast = do_raycast(1000.0)
        if raycast.did_hit then
            ptfx_play_at_coords(raycast.hit_coords, ptfx[1], ptfx[2], ptfx_color)
            util.yield(ptfx[3])
        end
    end
end)

ptfx_create_list(self_ptfx_weapon_muzzle_root, function(ptfx)
    local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(player_get_ped())
    if weapon ~= NULL then
        ptfx_play_at_entity_bone_coords(weapon, WeaponBones.Muzzle, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

ptfx_create_list(self_ptfx_weapon_muzzle_flash_root, function(ptfx)
    local player_ped = player_get_ped()
    if PED.IS_PED_SHOOTING(player_ped) then
        local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(player_ped)
        if weapon ~= NULL then
            ptfx_play_at_entity_bone_coords(weapon, WeaponBones.Muzzle, ptfx[1], ptfx[2], ptfx_color)
            util.yield(ptfx[3])
        end
    end
end)

ptfx_create_list(self_ptfx_weapon_impact_root, function(ptfx)
    local impact_ptr = memory.alloc()
    if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(player_get_ped(), impact_ptr) then
        ptfx_play_at_coords(memory.read_vector3(impact_ptr), ptfx[1], ptfx[2], ptfx_color)
        memory.free(impact_ptr)
    end
end)

-- -- Pointing PTFX
self_ptfx_pointing_finger_root = menu.list(world_ptfx_pointing_root, "Finger...", {"ryanptfxpointingfinger"}, "Special FX on your left finger.")
self_ptfx_pointing_crosshair_root = menu.list(world_ptfx_pointing_root, "Crosshair...", {"ryanptfxpointingfinger"}, "Special FX on your crosshair.")

ptfx_create_list(self_ptfx_pointing_finger_root, function(ptfx)
    if memory.read_int(memory.script_global(4516656 + 930)) == 3 then
        ptfx_play_on_entity_bones(player_get_ped(), PlayerBones.Pointer, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

ptfx_create_list(self_ptfx_pointing_crosshair_root, function(ptfx)
    if player_is_pointing then
        local raycast = do_raycast(1000.0)
        if raycast.did_hit then
            ptfx_play_at_coords(raycast.hit_coords, ptfx[1], ptfx[2], ptfx_color)
            util.yield(ptfx[3])
        end
    end
end)

-- -- Tiny People
world_tiny_people = false
menu.toggle(world_root, "Tiny People", {"ryantinypeople"}, "Makes everyone tiny (only for you.)", function(value)
    world_tiny_people = value
end)
util.create_tick_handler(function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        PED.SET_PED_CONFIG_FLAG(ped, 223, world_tiny_people)
    end
    util.yield(100)
end)

-- -- Crosshair When Pointing
world_crosshair_when_pointing = false
player_is_pointing = false

menu.toggle(world_root, "Crosshair When Pointing", {"ryanpointingcrosshair"}, "Adds a crosshair when pointing.", function(value)
    world_crosshair_when_pointing = value
end)

-- -- Del Perro Fireworks
menu.toggle_loop(world_root, "Del Perro Fireworks", {"ryanfireworkshow"}, "A nice display of liberty on the second worst beach in America.", function()
    function spawn_firework(burst_type, coords, color)
        coords = vector_add({x = -1800, y = -1000, z = 85}, coords)
        ptfx_play_at_coords(coords, PTFX[burst_type][1], PTFX[burst_type][2], color)
        audio_play_at_coords(coords, "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 100)
        audio_play_at_coords(vector_add(coords, {x = 50, y = 50, z = 0}), "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 500)
        audio_play_at_coords(vector_add(coords, {x = -50, y = -50, z = 0}), "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 500)
        audio_play_at_coords(vector_add(coords, {x = 75, y = 75, z = 0}), "PLAYER_SWITCH_CUSTOM_SOUNDSET", "Hit_Out", 100)
    end

    local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
    spawn_firework("Firework Burst", {x = math.random(-150, 150), y = math.random(-200, 50), z = math.random(-25, 25)}, color)

    if math.random(1, 10) == 2 then
        local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
        local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
        spawn_firework("Firework Burst", vector_add(offset, {x = 8, y = 8, z = 0}), color)
        spawn_firework("Firework Burst", vector_add(offset, {x = -8, y = 8, z = 0}), color)
        spawn_firework("Firework Burst", vector_add(offset, {x = 8, y = -8, z = 0}), color)
        spawn_firework("Firework Burst", vector_add(offset, {x = -8, y = -8, z = 0}), color)
    end
    if math.random(1, 10) == 8 then
        local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
        local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
        for i = 1, math.random(3, 6) do
            util.yield(math.random(25, 250))
            spawn_firework("Firework Burst", vector_add(offset, {x = 8, y = i + 8, z = 0}), color)
            spawn_firework("Firework Burst", vector_add(offset, {x = 8, y = -i - 8, z = 0}), color)
        end
    end

    util.yield(math.random(150, 650))
end)


-- Session Menu --
session_vehicles_root = menu.list(session_root, "Vehicles...", {"ryanplayervehicles"}, "Vehicle options for all players in the session.")
session_trolling_root = menu.list(session_root, "Trolling...", {"ryantrolling"}, "Trolling options on all players.")
session_nuke_root = menu.list(session_root, "Nuke...", {"ryannuke"}, "Plays a siren, timer, and bomb with additional earrape.")
session_dox_root = menu.list(session_root, "Dox...", {"ryandox"}, "Shares information players probably want private.")

-- -- Downgrade Vehicle
menu.action(session_vehicles_root, "Downgrade", {"ryandowngrade"}, "Downgrades every player's car.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_upgraded(vehicle, false)
            end
        end
        util.toast("Downgraded everyone's car!")
    end
end)

-- -- Make Vehicle Slow
menu.action(session_vehicles_root, "Make Slow", {"ryanslow"}, "Slows every player's car.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_speed(vehicle, false)
            end
        end
        util.toast("Made everyone's car slow!")
    end
end)

-- -- Make Vehicle Fast
menu.action(session_vehicles_root, "Make Fast", {"ryanfast"}, "Speeds up every player's car.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_speed(vehicle, true)
            end
        end
        util.toast("Made everyone's car fast!")
    end
end)

-- -- Make Vehicle Drift
menu.action(session_vehicles_root, "Make Drift", {"ryandrift"}, "Makes every player's car lose grip.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_no_grip(vehicle, true)
            end
        end
        util.toast("Made everyone's car drift!")
    end
end)

-- -- Lock Doors
menu.action(session_vehicles_root, "Lock Doors", {"ryanlock"}, "Locks every player's car.", function()
    for _, player_id in pairs(players.list()) do 
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_lock_doors(vehicle, true)
            end
        end
        util.toast("Locked everyone's car!")
    end
end)

-- -- Burst Tires
menu.action(session_vehicles_root, "Burst Tires", {"ryanburst"}, "Burst the tires of every player's car.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_burst_tires(vehicle)
            end
        end
        util.toast("Bursted everyone's tires!")
    end
end)

-- -- Catapult
menu.action(session_vehicles_root, "Catapult", {"ryancatapult"}, "Catapults every player's car.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_catapult(vehicle)
            end
        end
    end
    util.toast("Catapulted everyone's car!")
end)

-- -- Mass Trolling
trolling_watch_time = 5000
trolling_include_modders = false
menu.slider(session_trolling_root, "Watch Time", {"ryanwatchtime"}, "Seconds to watch the chaos unfold per player.", 1, 15, 5, 1, function(value)
    trolling_watch_time = value * 1000
end)
menu.toggle(session_trolling_root, "Include Modders", {"ryanincludemodders"}, "Whether to include modders in the mass trolling.", function(value)
    trolling_include_modders = value
end)

menu.divider(session_trolling_root, "Attacker")
menu.action(session_trolling_root, "Clone", {"ryanattackallclone"}, "Sends an angry clone to attack all players.", function()
    util.toast("Sending a clone after all players...")
    watch_and_trigger_command_all({"enemyclone{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Chop", {"ryanattackallchop"}, "Sends Chop to attack all players.", function()
    util.toast("Sending Chop after all players...")
    watch_and_trigger_command_all({"sendchop{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Police", {"ryanattackallpolice"}, "Sends the law to attack all players.", function()
    util.toast("Sending a police car after all players...")
    watch_and_trigger_command_all({"sendpolicecar{name}"}, trolling_include_modders, trolling_watch_time)
end)

menu.divider(session_trolling_root, "Vehicle")
menu.action(session_trolling_root, "Tow", {"ryantowall"}, "Sends a tow truck to all players.", function()
    util.toast("Towing all players...")
    watch_and_trigger_command_all({"towtruck{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Catapult", {"ryancatapultall"}, "Catapults everyone's vehicles.", function()
    util.toast("Catapulting all players...")
    watch_and_takeover_vehicle_all(function(vehicle)
        vehicle_catapult(vehicle)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Burst Tires", {"ryanbursttiresall"}, "Bursts everyone's tires.", function()
    util.toast("Bursting all tires...")
    watch_and_takeover_vehicle_all(function(vehicle)
        vehicle_burst_tires(vehicle)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Kill Engine", {"ryankillengineall"}, "Kills everyone's engine.", function()
    util.toast("Killing all engines...")
    watch_and_takeover_vehicle_all(function(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
    end, trolling_include_modders, trolling_watch_time)
end)

-- -- Nuke
nuke_spam_enabled = false
nuke_spam_message = "Get Ryan's Menu for Stand!"

menu.action(session_nuke_root, "Start Nuke", {"ryannukestart"}, "Starts the nuke.", function()
    util.toast("Nuke incoming.")
    audio_play_on_all_players("DLC_sum20_Business_Battle_AC_Sounds", "Air_Defences_Activated"); util.yield(3000)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(1000)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(1000)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(500)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(500)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    audio_play_on_all_players("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    explode_all(true)
    if nuke_spam_enabled then
        if not STAND_DOESNT_LIKE_SPAM_CHAT then
            spam_chat(nuke_spam_message, true, 100, 0)
        else
            menu.trigger_commands("spam on")
            util.yield(3000)
            menu.trigger_commands("spam off")
        end
    end
end)
menu.divider(session_nuke_root, "Options")
menu.toggle(session_nuke_root, "Enable Spam", {"ryannukespam"}, "If enabled, spams the chat upon impact.", function(value)
    nuke_spam_enabled = value
end)
menu.text_input(session_nuke_root, "Spam Message", {"ryannukemessage"}, "The message that will be spammed.", function(value)
    nuke_spam_message = value
end, "Get Ryan's Menu for Stand!")

-- -- Dox Players
menu.action(session_dox_root, "Richest & Poorest", {"ryanrichest"}, "Shares the name of the richest and poorest players.", function()
    player_list_by_money()
end)
menu.action(session_dox_root, "K/D Ratio", {"ryankd"}, "Shares the name of the highest and lowest K/D players.", function()
    player_list_by_kd()
end)
menu.action(session_dox_root, "Godmode", {"ryangodmode"}, "Shares the name of the players in godmode.", function()
    player_list_by_godmode()
end)
menu.action(session_dox_root, "Off Radar", {"ryanoffradar"}, "Shares the name of the players off the radar.", function()
    player_list_by_offradar()
end)
menu.action(session_dox_root, "Oppressor", {"ryanoppressor"}, "Shares the name of the players in Oppressors.", function()
    player_list_by_oppressor2()
end)

-- -- Omnicrash
session_omnicrash_root = menu.list(session_root, "Omnicrash", {"ryanomnicrashall"}, "The ultimate session crash.")
session_omnicrash_friends = false
session_omnicrash_modders = true

menu.action(session_omnicrash_root, "Go", {"ryanomnicrashallgo"}, "Attempts to crash using all known script events.", function()
    for _, player_id in pairs(players.list(false, session_omnicrash_friends)) do
        if session_omnicrash_modders or not players.is_marked_as_modder(player_id) then
            util.create_thread(function()
                do_omnicrash(player_id)
            end)
        end
    end
end)

menu.divider(session_omnicrash_root, "Options")
menu.toggle(session_omnicrash_root, "Include Friends", {"ryanomnicrashfriends"}, "If enabled, friends are included in the Omnicrash.", function(value)
    session_omnicrash_friends = value
end)
menu.toggle(session_omnicrash_root, "Include Modders", {"ryanomnicrashmodders"}, "If enabled, modders are included in the Omnicrash.", function(value)
    session_omnicrash_modders = value
end)

-- -- All Players Visible
menu.toggle_loop(session_root, "All Players Visible", {"ryannoinvisible"}, "Makes all invisible players visible again.", function()
    for _, player_id in pairs(players.list()) do
        ENTITY.SET_ENTITY_VISIBLE(player_get_ped(player_id), true, 0)
    end
end, false)

-- -- Fake Money Drop
menu.toggle_loop(session_root, "Fake Money Drop", {"ryanfakemoneyall"}, "Drops fake money bags on all players.", function()
    for _, player_id in pairs(players.list()) do
        util.create_thread(function()
            do_fake_money_drop(player_id)
        end)
    end
    util.yield(125)
end, false)

-- -- Mk II Chaos
menu.action(session_root, "Mk II Chaos", {"ryanmk2chaos"}, "Gives everyone a Mk 2 and requests them to duel.", function()
    local oppressor2 = util.joaat("oppressor2")
    request_model(oppressor2)
    for _, player_id in pairs(players.list()) do
        local player_ped = player_get_ped()
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 5.0, 0.0)
        local vehicle = entities.create_vehicle(oppressor2, coords, ENTITY.GET_ENTITY_HEADING(player_ped))
        vehicle_set_upgraded(vehicle, true)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, true)
        VEHICLE.SET_VEHICLE_DOOR_LATCHED(vehicle, 0, false, false, true)
    end
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(oppressor2)
    chat.send_message("Everyone has just received an Oppressor Mk 2 with missiles. Battle it out!", false, true, true)
end)


-- Stats Menu --
stats_office_money_root = menu.list(stats_root, "CEO Office Money...", {"ryanofficemoney"}, "Controls the amount of money in your CEO office.")
stats_mc_clutter_root = menu.list(stats_root, "MC Clubhouse Clutter...", {"ryanmcclutter"}, "Controls the amount of clutter in your clubhouse.")

-- -- CEO Office Money
office_money_0 = menu.action(stats_office_money_root, "0% Full", {"ryanofficemoney0"}, "Makes the office 0% full with money.", function(click_type)
    set_office_money(office_money_0, click_type, 0)
end)
office_money_25 = menu.action(stats_office_money_root, "25% Full", {"ryanofficemoney25"}, "Makes the office 25% full with money.", function(click_type)
    set_office_money(office_money_25, click_type, 5000000)
end)
office_money_50 = menu.action(stats_office_money_root, "50% Full", {"ryanofficemoney50"}, "Makes the office 50% full with money.", function(click_type)
    set_office_money(office_money_50, click_type, 10000000)
end)
office_money_75 = menu.action(stats_office_money_root, "75% Full", {"ryanofficemoney75"}, "Makes the office 75% full with money.", function(click_type)
    set_office_money(office_money_75, click_type, 15000000)
end)
office_money_100 = menu.action(stats_office_money_root, "100% Full", {"ryanofficemoney100"}, "Makes the office 100% full with money.", function(click_type)
    set_office_money(office_money_100, click_type, 20000000)
end)

-- -- MC Clubhouse Clutter
mc_clutter_0 = menu.action(stats_mc_clutter_root, "0% Full", {"ryanmcclutter0"}, "Removes drugs, money, and other clutter to your M.C. clubhouse.", function(click_type)
    set_mc_clutter(mc_clutter_0, click_type, 0)
end)
mc_clutter_100 = menu.action(stats_mc_clutter_root, "100% Full", {"ryanmcclutter100"}, "Adds drugs, money, and other clutter to your M.C. clubhouse.", function(click_type)
    set_mc_clutter(mc_clutter_100, click_type, 20000000)
end)


-- Player Options --
function setup_player(player_id)
    local player_root = menu.player_root(player_id)
    menu.divider(player_root, "Ryan's Menu")
    
    local player_trolling_root = menu.list(player_root, "Trolling...", {"ryantrolling"}, "Options that players may not like.")
    local player_trolling_vehicle_root = menu.list(player_trolling_root, "Vehicle...", {"ryanvehicle"}, "Vehicle trolling options.")

    local player_removal_root = menu.list(player_root, "Removal...", {"ryanremoval"}, "Options to remove the player forcibly.")


    -- Trolling --
    -- -- Downgrade Vehicle
    menu.action(player_trolling_vehicle_root, "Downgrade", {"ryandowngrade"}, "Downgrades the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_upgraded(vehicle, false)
            end
        end
        util.toast("Downgraded " .. PLAYER.GET_PLAYER_NAME(player_id) .. "'s car!")
    end)

    -- -- Make Vehicle Slow
    menu.action(player_trolling_vehicle_root, "Make Slow", {"ryanslow"}, "Slows the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_speed(vehicle, false)
            end
        end
        util.toast("Made " .. PLAYER.GET_PLAYER_NAME(player_id) .. "'s car slow!")
    end)

    -- -- Make Vehicle Fast
    menu.action(player_trolling_vehicle_root, "Make Fast", {"ryanfast"}, "Speeds up the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_speed(vehicle, true)
            end
        end
        util.toast("Made " .. PLAYER.GET_PLAYER_NAME(player_id) .. "'s car fast!")
    end)

    -- -- Make Vehicle Drift
    menu.action(player_trolling_vehicle_root, "Make Drift", {"ryandrift"}, "Makes the car they are in lose grip.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_no_grip(vehicle, true)
            end
        end
        util.toast("Made " .. PLAYER.GET_PLAYER_NAME(player_id) .. "'s car drift!")
    end)

    -- -- Lock Doors
    menu.action(player_trolling_vehicle_root, "Lock Doors", {"ryanlock"}, "Locks the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_lock_doors(vehicle, true)
            end
        end
        util.toast("Locked " .. PLAYER.GET_PLAYER_NAME(player_id) .. "'s car!")
    end)

    -- -- Burst Tires
    menu.action(player_trolling_vehicle_root, "Burst Tires", {"ryanburst"}, "Burst the tires of the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_burst_tires(vehicle)
            end
        end
        util.toast("Bursted " .. PLAYER.GET_PLAYER_NAME(player_id) .. "'s tires!")
    end)

    -- -- Catapult
    menu.action(player_trolling_vehicle_root, "Catapult", {"ryancatapult"}, "Catapults the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_catapult(vehicle)
            end
        end
        util.toast("Catapulted " .. PLAYER.GET_PLAYER_NAME(player_id) .. "'s car!")
    end)

    -- -- No Godmode
    local remove_godmode_notice = 0
    menu.toggle_loop(player_trolling_root, "No Godmode", {"ryannogodmode"}, "Removes godmode from Kiddions users and their vehicles.", function()
        player_remove_godmode(player_id, true)
        if util.current_time_millis() - remove_godmode_notice >= 10000 then
            util.toast("Still removing godmode from " .. PLAYER.GET_PLAYER_NAME(player_id) .. ".")
            remove_godmode_notice = util.current_time_millis()
        end
    end, false)

    -- -- Fake Money Drop
    menu.toggle_loop(player_trolling_root, "Fake Money Drop", {"ryanfakemoney"}, "Drops fake money bags on the player.", function()
        util.create_thread(function()
            do_fake_money_drop(player_id)
        end)
        util.yield(125)
    end, false)

    -- -- Stripper El Rubio
    menu.action(player_trolling_root, "Stripper El Rubio", {"ryanelrubio"}, "Spawns an El Rubio whose fortune has been stolen, leading him to the pole.", function()
        local ped_coords = vector_add(
            ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id)),
            {x = math.random(-5, 5), y = math.random(-5, 5), z = 0}
        )

        --local pole = util.joaat("prop_fnccorgm_02pole"); request_model(pole)
        local el_rubio = util.joaat("csb_juanstrickler"); request_model(el_rubio)
        request_animations("mini@strip_club@pole_dance@pole_dance1")

        --local object = entities.create_object(pole, object_coords)
        local ped = entities.create_ped(1, el_rubio, ped_coords, ENTITY.GET_ENTITY_HEADING(player_get_ped(player_id)))
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(el_rubio)
        HUD.ADD_BLIP_FOR_ENTITY(ped)
        entity_request_control_loop(ped)
        TASK.TASK_PLAY_ANIM(ped, "mini@strip_club@pole_dance@pole_dance1", "pd_dance_01", 8.0, 0, -1, 9, 0, false, false, false)

        util.yield(300000)
        entities.delete_by_handle(ped)
    end)

    -- -- Trash Pickup
    menu.action(player_trolling_root, "Send Trash Pickup", {"ryantrashpickup"}, "Send the trash man to 'clean up' the street. Yasha's idea.", function()
        do_trash_pickup(player_id)
    end)
    

    -- Removal --
    -- -- Text & Kick
    local text_kick_root = menu.list(player_removal_root, "Text & Kick...", {"ryantextkick"}, "Kicks the player after spamming them with texts.")
    local text_kick_duration = 6000
    local text_kick_block_joins = false
    local text_kick_message = "See you later, child baiter."
    menu.text_input(text_kick_root, "Message", {"ryantextkickmessage"}, "The message to spam before kicking.", function(value)
        text_kick_message = value
    end, text_kick_message)
    menu.slider(text_kick_root, "Text Spam Duration", {"ryantextkickduration"}, "Duration in milliseconds of text spam.", 5000, 10000, 6000, 500, function(value)
        text_kick_duration = value
    end)
    menu.toggle(text_kick_root, "Block Joins", {"ryantextkickblockjoins"}, "Block joins by this player.", function(value)
        text_kick_block_joins = value
    end)
    menu.action(text_kick_root, "Go", {"ryantextkickgo"}, "Start the text & kick.", function()
        local player_name = PLAYER.GET_PLAYER_NAME(player_id)
        
        util.toast("Spamming " .. player_name .. " with texts...")
        do_sms_spam(player_id, text_kick_message, text_kick_duration)

        util.toast("Kicking " .. player_name .. "!")
        if text_kick_block_joins then
            player_block(player_name)
        end
        menu.trigger_commands("kick" .. player_name)
        util.yield()
        menu.trigger_commands("breakup" .. player_name)
        menu.trigger_commands("players")
    end)

    -- -- Omnicrash
    menu.action(player_removal_root, "Omnicrash Mk II", {"ryanomnicrash"}, "Attempts to crash using all known script events.", function()
        do_omnicrash(player_id)
    end)

    -- -- Smelly Peepo Crash (Credit: 2take1 Additions, Keramis Script)
    menu.action(player_removal_root, "Smelly Peepo Crash", {"ryansmellypeepo"}, "Attempts to crash using invalid and bugged peds.", function()
        show_text_message(Colors.Purple, "Smelly Peepo Crash", "Smelly Peepo Crash has begun. This may take a while...")
        
        local player_ped = player_get_ped(player_id)
        local player_ped_heading = ENTITY.GET_ENTITY_HEADING(player_ped)
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)

        util.toast("Spawning smelly objects on " .. PLAYER.GET_PLAYER_NAME(player_id))
        request_model(-930879665)
        request_model(3613262246)
        request_model(452618762)
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

        util.toast("Spawning smelly peds on " .. PLAYER.GET_PLAYER_NAME(player_id) .. "...")
        local ped = entities.create_ped(0, 1057201338, player_coords, 0)
        util.yield(100)
        entities.delete_by_handle(ped)
        local ped = entities.create_ped(0, -2056455422, player_coords, 0)
        util.yield(100)
        entities.delete_by_handle(ped)
        local ped = entities.create_ped(0, 762327283, player_coords, 0)
        util.yield(100)
        entities.delete_by_handle(ped)

        util.toast("Spawning the smelliest of peds on " .. PLAYER.GET_PLAYER_NAME(player_id) .. "!")
        local fatcult = util.joaat("a_f_m_fatcult_01"); request_model(fatcult)
        for i = 1, 8 do
            util.create_thread(function()
                local ped = entities.create_ped(
                    0, fatcult,
                    vector_add(player_coords, {x = math.random(-1, 1), y = math.random(-1, 1), z = 0}),
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
            player_send_script_event(player_id, {962740265, player_id, 23243, 5332, 3324, player_id}, "final payload")
        end
        util.toast("Done!")
    end)


    -- Divorce Kick --
    menu.action(player_root, "Divorce", {"ryandivorce"}, "Kicks the player, then blocks future joins by them.", function()
        local player = PLAYER.GET_PLAYER_NAME(player_id)
        player_block_joins(player)
        menu.trigger_commands("kick" .. player)
        util.yield()
        menu.trigger_commands("breakup" .. player)
        menu.trigger_commands("players")
    end)
end


-- Chat Menu --
chat_message = ""
chat_prefix = ""

-- -- Message
menu.text_input(chat_root, "Message", {"ryanchatmessage"}, "The message to send in chat.", function(value)
    chat_message = value
end, "")

-- -- Logo
chat_prefix_root = menu.list(chat_root, "Logo: None", {"ryanchatlogo"}, "Adds a special logo to the beginning of the message.")
menu.action(chat_prefix_root, "Rockstar", {"ryanchatlogors"}, "Adds the Rockstar logo.", function()
    menu.set_menu_name(chat_prefix_root, "Logo: Rockstar")
    menu.focus(chat_prefix_root)
    chat_prefix = "∑ "
end)
menu.action(chat_prefix_root, "Rockstar Verified", {"ryanchatlogorsverified"}, "Adds the Rockstar Verified logo.", function()
    menu.set_menu_name(chat_prefix_root, "Logo: Rockstar Verified")
    menu.focus(chat_prefix_root)
    chat_prefix = "¦ "
end)
menu.action(chat_prefix_root, "Lock", {"ryanchatlogors"}, "Adds the lock logo.", function()
    menu.set_menu_name(chat_prefix_root, "Logo: Lock")
    menu.focus(chat_prefix_root)
    chat_prefix = "Ω "
end)

-- -- Send Message
chat_send_root = menu.list(chat_root, "Send...", {"ryantranslatesend"}, "Translate and send the message.")
menu.action(chat_send_root, "Send", {"ryanchatsend"}, "Send without translating.", function()
    chat.send_message(chat_prefix .. chat_message, false, true, true)
    menu.focus(chat_send_root)
end)

menu.divider(chat_send_root, "Translate")
menu.action(chat_send_root, "Spanish", {"ryantranslatespanish"}, "Translate to Spanish.", function()
    util.toast("Translating message to Spanish...")
    send_translated(chat_prefix .. chat_message, "ES", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Russian", {"ryantranslaterussian"}, "Translate to Russian.", function()
    util.toast("Translating message to Russian...")
    send_translated(chat_prefix .. chat_message, "RU", true)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Russian (Cyrillic)", {"ryantranslatecyrillic"}, "Translate to Russian (Cyrillic).", function()
    util.toast("Translating message to Russian (Cyrillic)...")
    send_translated(chat_prefix .. chat_message, "RU", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "French", {"ryantranslatefrench"}, "Translate to French.", function()
    util.toast("Translating message to French...")
    send_translated(chat_prefix .. chat_message, "FR", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "German", {"ryantranslategerman"}, "Translate to German.", function()
    util.toast("Translating message to German...")
    send_translated(chat_prefix .. chat_message, "DE", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Italian", {"ryantranslateitalian"}, "Translate to Italian.", function()
    util.toast("Translating message to Italian...")
    send_translated(chat_prefix .. chat_message, "IT", false)
    menu.focus(chat_send_root)
end)


-- Settings Menu --
menu.divider(settings_root, "Updates")
menu.action(settings_root, "Version: " .. VERSION, {}, "The currently installed version.", function() end)
menu.hyperlink(settings_root, "Get Latest Version", "https://github.com/RyanGarber/Ryans-Menu/raw/main/Ryan's Menu.lua", "Opens the latest version of the menu for downloading.")


-- Initialize --
players.on_join(function(player_id) setup_player(player_id) end)
players.dispatch_on_join()

util.keep_running()


-- DirectX --
while true do
    player_is_pointing = memory.read_int(memory.script_global(4516656 + 930)) == 3
    if world_crosshair_when_pointing and player_is_pointing then
        directx.draw_texture(
            CrosshairTexture,
            0.03, 0.03,
            0.5, 0.5,
            0.5, 0.5,
            0.0,
            {["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0}
        )
    end
    util.yield()
end