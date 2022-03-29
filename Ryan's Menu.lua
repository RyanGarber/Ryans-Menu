version = "0.4.8"
notify_requirements = false

-- Requirements --
while not filesystem.exists(filesystem.scripts_dir() .. "lib\\natives-1640181023.lua") do
    if not notify_requirements then
        local ref = menu.ref_by_path("Stand>Lua Scripts>Repository>WiriScript")
        menu.focus(ref)
        notify_requirements = true
    end

    util.toast("Ryan's Menu requires LanceScript and WiriScript to function. Please enable them to continue.")
    util.yield(2000)
end

require("natives-1640181023")

-- Check for Updates --
util.toast("Welcome to Ryan's Menu v" .. version ..". Checking for updates...")
async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/VERSION?nocache=" .. math.random(0, 1000000), function(latest_version)
    latest_version = latest_version:gsub("\n", "")
    if latest_version ~= version then
        util.toast("The version you are using is outdated! Press Get Latest Version to get v" .. latest_version .. ".")
        menu.trigger_commands("ryansettings")
    else
        util.toast("You're up to date! Enjoy :)")
    end
    AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Object_Dropped_Remote", PLAYER.PLAYER_PED_ID(), "GTAO_FM_Events_Soundset", true, 20)
end, function()
    util.toast("Failed to get the latest version. Go to Settings and press Get Latest Version to check manually.")
end)
async_http.dispatch()


-- Globals --
EARRAPE_NONE = 0
EARRAPE_BED = 1
EARRAPE_FLASH = 2

RUSSIAN_ALPHABET = {
    ["A"] = "A", ["a"] = "a", ["Б"] = "B", ["б"] = "b",
    ["В"] = "V", ["в"] = "v", ["Г"] = "G", ["г"] = "g",
    ["Д"] = "D", ["д"] = "d", ["Е"] = "E", ["e"] = "e",
    ["Ё"] = "Yo", ["ё"] = "yo", ["Ж"] = "Zh", ["ж"] = "zh",
    ["З"] = "Z", ["з"] = "z", ["И"] = "I", ["и"] = "i",
    ["Й"] = "J", ["й"] = "j", ["К"] = "K", ["к"] = "k",
    ["Л"] = "L", ["л"] = "l", ["М"] = "M", ["м"] = "m",
    ["Н"] = "N", ["н"] = "n", ["О"] = "O", ["о"] = "o",
    ["П"] = "P", ["п"] = "p", ["Р"] = "R", ["р"] = "r",
    ["С"] = "S", ["с"] = "s", ["Т"] = "T", ["т"] = "t",
    ["У"] = "U", ["у"] = "u", ["Ф"] = "F", ["ф"] = "f",
    ["Х"] = "H", ["х"] = "h", ["Ц"] = "Ts", ["ц"] = "ts",
    ["Ч"] = "Ch", ["ч"] = "ch", ["Ш"] = "Sh", ["ш"] = "sh",
    ["Щ"] = "Shch", ["щ"] = "shch", ["Ъ"] = "'", ["ъ"] = "'",
    ["Ы"] = "Y", ["ы"] = "y", ["Ь"] = "'", ["ь"] = "'",
    ["Э"] = "E", ["э"] = "e", ["Ю"] = "Yu", ["ю"] = "yu",
    ["Я"] = "Ya", ["я"] = "ya"
}

ACTION_FIGURES = {
    {3514,3754,35}, {3799,4473,7}, {3306,5194,18}, {2937,4620,48}, {2725,4142,44},
    {2487,3759,43}, {1886,3913,33}, {1702,3290,48}, {1390,3608,34}, {1298,4306,37},
    {1714,4791,41}, {2416,4994,46}, {2221,5612,55}, {1540,6323,24}, {1310,6545,5},
    {457,5573,781}, {178,6394,31}, {-312,6314,32}, {-689,5829,17}, {-552,5330,75},
    {-263,4729,138}, {-1121,4977,186}, {-2169,5192,17}, {-2186,4250,48}, {-2172,3441,31},
    {-1649,3018,32}, {-1281,2550,18}, {-1514,1517,111}, {-1895,2043,142}, {-2558,2316,33},
    {-3244,996,13}, {-2959,386,14}, {-3020,41,10}, {-2238,249,176}, {-1807,427,132},
    {-1502,813,181}, {-770,877,204}, {-507,393,97}, {-487,-55,39}, {-294,-343,10},
    {-180,-632,49}, {-108,-857,39}, {-710,-906,19}, {-909,-1149,2}, {-1213,-960,1},
    {-1051,-523,36},{-989,-102,40}, {-1024,190,62}, {-1462,182,55}, {-1720,-234,55},
    {-1547,-449,40}, {-1905,-710,8}, {-1648,-1095,13}, {-1351,-1547,4}, {-887,-2097,9},
    {-929,-2939,13}, {153,-3078,7}, {483,-3111,6}, {-56,-2521,7}, {368,-2114,17},
    {875,-2165,32}, {1244,-2573,43}, {1498,-2134,76}, {1207,-1480,34}, {679,-1523,9},
    {379,-1510,29}, {-44,-1749,29}, {-66,-1453,32}, {173,-1209,30}, {657,-1047,22},
    {462,-766,27}, {171,-564,22},{621,-410,-1}, {1136,-667,57}, {988,-138,73},
    {1667,0,166}, {2500,-390,95}, {2549,385,108}, {2618,1692,31}, {1414,1162,114},
    {693,1201,345}, {660,549,130}, {219,97,97}, {-141,234,99}, {87,812,211},
    {-91,939,233}, {-441,1596,358}, {-58,1939,190}, {-601,2088,132}, {-300,2847,55},
    {63,3683,39}, {543,3074,40}, {387,2570,44}, {852,2166,52}, {1408,2157,98},
    {1189,2641,38}, {1848,2700,63}, {2635,2931,44}, {2399,3063,54}, {2394,3062,52}
}
SIGNAL_JAMMERS = {
    {-3096,783,33}, {-2273,325,195}, {-1280,304,91}, {-1310,-445,108}, {-1226,-866,82},
    {-1648,-1125,29}, {-686,-1381,24}, {-265,-1897,54}, {-988,-2647,89}, {-250,-2390,124},
    {554,-2244,74}, {978,-2881,33}, {1586,-2245,130}, {1110,-1542,55}, {405,-1387,75},
    {-1,-1018,95}, {-182,-589,210}, {-541,-213,82}, {-682,228,154}, {-421,1142,339},
    {-296,2839,68}, {753,2596,133}, {1234,1869,92}, {760,1263,444}, {677,556,153},
    {220,224,168}, {485,-109,136}, {781,-705,47}, {1641,-33,178}, {2442,-383,112},
    {2580,444,115}, {2721,1519,85}, {2103,1754,138}, {1709,2658,60}, {1859,3730,116},
    {2767,3468,67}, {3544,3686,60}, {2895,4332,101}, {3296,5159,29}, {2793,5984,366},
    {1595,6431,32}, {-119,6217,62}, {449,5595,793}, {1736,4821,60}, {732,4099,37},
    {-492,4428,86}, {-1018,4855,301}, {-2206,4299,54}, {-2367,3233,103}, {-1870,2069,154}
}
PLAYING_CARDS = {
    {-1028,-2747,14}, {-74,-2005,18}, {202,-1645,29}, {120,-1298,29}, {11,-1102,29},
    {-539,-1279,27}, {-1205,-1560,4}, {-1288,-1119,7}, {-1841,-1235,13}, {-1155,-528,31},
    {-1167,-234,37}, {-971,104,55}, {-1513,-105,54}, {-3048,585,7}, {-3150,1115,20},
    {-1829,798,138}, {-430,1214,325}, {-409,585,125}, {-103,368,112}, {253,215,106},
    {-168,-298,40}, {183,-686,43}, {1131,-983,46}, {1159,-317,69}, {548,-190,54}, 
    {1487,1128,114}, {730,2514,73}, {188,3075,43}, {-288,2545,75}, {-1103,2714,19}, 
    {-2306,3388,31}, {-1583,5204,4}, {-749,5599,41}, {-283,6225,31}, {99,6620,32}, 
    {1876,6410,46}, {2938,5325,101}, {3688,4569,25}, {2694,4324,45}, {2120,4784,40}, 
    {1707,4920,42}, {727,4189,41}, {-524,4193,193}, {79,3704,41}, {900,3557,33}, 
    {1690,3588,35}, {1991,3045,47}, {2747,3465,55}, {2341,2571,47}, {2565,297,108}, 
    {1325,-1652,52}, {989,-1801,31}, {827,-2159,29}, {810,-2979,6} 
}


-- Helper Functions --
function get_closest_vehicle(coords) -- Credit: Lance Script
    local vehicles = entities.get_all_vehicles_as_handles()
    local closest_distance = 1000000
    local closest_vehicle = 0
    for k, vehicle in pairs(vehicles) do
        if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false) then
            local vehicle_coords = get_coords(vehicle)
            local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(
                coords['x'], coords['y'], coords['z'],
                vehicle_coords['x'], vehicle_coords['y'], vehicle_coords['z'], true
            )
            if distance < closest_distance then
                closest_distance = distance
                closest_vehicle = vehicle
            end
        end
    end
    return closest_vehicle
end

function vehicle_control_loop(entity) -- Credit: WiriScript
    local tick = 0
    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and tick < 25 do
        util.yield()
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        tick = tick + 1
    end
    if NETWORK.NETWORK_IS_SESSION_STARTED() then
        local network_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
        util.toast("Took control of a vehicle.")
    end
end

function block_joins(player) -- Credit: Block Joins Script
    local ref
    local possible_tags = {" [Offline/Story Mode]", " [Public]", " [Solo/Invite-Only]", ""}
    local success = false
    for i = 1, #possible_tags do
        if pcall(function()
            ref = menu.ref_by_path("Online>Player History>" .. player .. possible_tags[i] .. ">Player Join Reactions>Block Join")
        end) then
            menu.focus(menu.my_root())
            menu.focus(ref)
            menu.trigger_command(ref, "true")
            success = true
            break
        else

        end
    end
    if success then
        util.toast("Blocked all future joins by that player.")
    else
        util.toast("Failed to block joins.")
    end
end

function remove_godmode(player_id, vehicle) -- Credit: KeramiScript
    if NETWORK.NETWORK_IS_PLAYER_CONNECTED(player_id) then
        if vehicle then
            local player_ped = PLAYER.GET_PLAYER_PED(player_id)
            if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
            end
        end
        util.trigger_script_event(1 << player_id, {801199324, player_id, 869796886})
    end
end

function format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function get_coords(entity)
    entity = entity or PLAYER.PLAYER_PED_ID()
    return ENTITY.GET_ENTITY_COORDS(entity, true)
end

function teleport_to(x, y, z)
    util.toast("Teleporting...")
    ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), x, y, z)
end

function teleport_vehicle_to(x, y, z)
    util.toast("Teleporting...")
    local player_ped = PLAYER.PLAYER_PED_ID()
    if PED.IS_PED_IN_ANY_VEHICLE(player_ped, true) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
        ENTITY.SET_ENTITY_COORDS(vehicle, x, y, z)
    else
        ENTITY.SET_ENTITY_COORDS(player_ped, x, y, z)
    end
end

function spam_chat(message, all_players, time_between, wait_for)
    local sent = 0
    while sent < 32 do
        if all_players then
            for k, player_id in pairs(players.list()) do
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

function play_all(sound, sound_group, wait_for)
    for i=0, 31, 1 do
        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound, PLAYER.GET_PLAYER_PED(i), sound_group, true, 20)
    end
    util.yield(wait_for)
end

function explode_all(earrape_type, wait_for)
    for i=0, 31, 1 do
        coords = get_coords(PLAYER.GET_PLAYER_PED(i))
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 100, true, false, 150, false)
        if earrape_type == EARRAPE_BED then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "Bed", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
        end
        if earrape_type == EARRAPE_FLASH then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
        end
    end
    util.yield(wait_for)
end

function run_all(commands, modders, wait_for)
    local starting_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    menu.trigger_commands("levitation on")
    for k, player_id in pairs(players.list()) do
        if PLAYER.PLAYER_PED_ID() ~= PLAYER.PLAYER_PED_ID(player_id) then
            if modders or not players.is_marked_as_modder(player_id) then
                local player_name = players.get_name(player_id)
                util.toast("Trolling player: " .. player_name .. "...")
                menu.trigger_commands("tp" .. player_name)
                util.yield(750)
                if player_name ~= "**invalid**" then
                    for i = 1, #commands do
                        menu.trigger_commands(commands[i]:gsub("{name}", player_name))
                    end
                end
                util.yield(wait_for)
            end
        end
    end
    teleport_to(starting_coords['x'], starting_coords['y'], starting_coords['z'])
    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
    menu.trigger_commands("levitation off")
end

function takeover_vehicle(action, player_id, wait_for)
    local player_name = players.get_name(player_id)
    util.toast("Trolling player: " .. players.get_name(player_id) .. "...")
    menu.trigger_commands("tpveh" .. player_name)
    util.yield(750)

    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id), false)
    if vehicle ~= NULL then
        vehicle_control_loop(vehicle)
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
            action(vehicle)
            util.yield(wait_for)
        end
    end
end

function takeover_vehicle_all(action, modders, wait_for)
    local starting_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    menu.trigger_commands("otr on")
    menu.trigger_commands("invisibility on")
    for k, player_id in pairs(players.list()) do
        if player_id ~= players.user() then
            if modders or not players.is_marked_as_modder(player_id) then
                takeover_vehicle(action, player_id, wait_for)
            end
        end
    end
    teleport_to(starting_coords['x'], starting_coords['y'], starting_coords['z'])
    menu.trigger_commands("otr off")
    menu.trigger_commands("invisibility off")
end

function send_translated(message, language, latin)
    async_http.init("ryan.gq", "/menu/translate?text=" .. message .. "&language=" .. language, function(result)
        if latin then
            for from, to in pairs(RUSSIAN_ALPHABET) do
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

function get_players_highest_and_lowest(get_value)
    local highest_amount = 0
    local highest_player = -1
    local lowest_amount = 2100000000
    local lowest_player = -1

    for k, player_id in pairs(players.list()) do
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

function get_players_boolean(get_value)
    local player_names = ""
    for k, player_id in pairs(players.list()) do
        if get_value(player_id) then
            player_names = player_names .. PLAYER.GET_PLAYER_NAME(player_id) .. ", "
        end
    end
    
    if player_names ~= "" then
        player_names = string.sub(player_names, 1, -3)
    end

    return player_names
end

function get_money(player_id)
    return players.get_wallet(player_id) + players.get_bank(player_id)
end

function get_offradar(player_id)
    return players.is_otr(player_id)
end

function get_godmode(player_id)
    return not players.is_in_interior(player_id) and players.is_godmode(player_id)
end

function get_oppressor2(player_id)
    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
    local hash = util.joaat("oppressor2")
    return VEHICLE.IS_VEHICLE_MODEL(vehicle, hash)
end


-- Player Sorting --
function get_players_by_money()
    data = get_players_highest_and_lowest(get_money)
    
    message = ""
    if data[1] ~= -1 then
        message = players.get_name(data[1]) .. " is the richest player here ($" .. format_int(data[2]) .. ")."
    end
    if data[1] ~= data[3] then
        message = message .. " " .. players.get_name(data[3]) .. " is the poorest ($" .. format_int(data[4]) .. ")."
    end
    if message ~= "" then
        chat.send_message(message, false, true, true)
        return
    end
end

function get_players_by_kd()
    data = get_players_highest_and_lowest(players.get_kd)
    
    message = ""
    if data[1] ~= -1 then
        message = players.get_name(data[1]) .. " has the highest K/D here (" .. string.format("%.1f", data[2]) .. ")."
    end
    if data[1] ~= data[3] then
        message = message .. " " .. players.get_name(data[3]) .. " has the lowest (" .. string.format("%.1f", data[4]) .. ")."
    end
    if message ~= "" then
        chat.send_message(message, false, true, true)
        return
    end
end

function get_players_by_godmode()
    local player_names = get_players_boolean(get_godmode)

    if player_names ~= "" then
        chat.send_message("Players likely in godmode: " .. player_names .. ".", false, true, true)
        return
    end

    chat.send_message("No players are in godmode.", false, true, true)
end

function get_players_by_offradar()
    local player_names = get_players_boolean(get_offradar)

    if player_names ~= "" then
        chat.send_message("Players off-the-radar: " .. player_names .. ".", false, true, true)
        return
    end

    chat.send_message("No players are off-the-radar.", false, true, true)
end

function get_players_by_oppressor2()
    local player_names = get_players_boolean(get_oppressor2)

    if player_names ~= "" then
        chat.send_message("Players on Oppressors: " .. player_names .. ".", false, true, true)
        return
    end

    chat.send_message("No players are on Oppressors.", false, true, true)
end

function do_office_money(amount)
    if not office_money_notice then
        util.toast("Make sure you have at least 1 crate of cargo, and run this option again.")
        office_money_notice = true
    else
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_COMPLETE"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_SELL_COMPLETE"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_UNDERTAKEN"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_UNDERTAKEN"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_CONTRA_EARNINGS"), amount, true)

        util.toast("Switch sessions and start a cargo sale to apply changes.")
        office_money_notice = false
    end
end

function do_mc_clutter(amount)
    if not mc_clutter_notice then
        util.toast("Make sure you have at least 1 unit to sell in each business, and run this option again.")
        mc_clutter_notice = true
    else
        for i=0, 5 do
            if i == 0 then i = "" end
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_BUY_COMPLET" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_BUY_UNDERTA" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_SELL_COMPLET" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_SELL_UNDERTA" .. i), 1000, true)
        end

        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS0"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS1"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS2"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS3"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS4"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS5"), 1000, true)

        util.toast("Switch sessions and start a sale in every business to apply changes.")
        mc_clutter_notice = false
    end
end

--menu.action(menu.my_root(), "Test", {"test"}, "Test", function() end)

-- Main Menu --
self_root = menu.list(menu.my_root(), "Self", {"ryanself"}, "Self options not commonly found in other scripts.")
world_root = menu.list(menu.my_root(), "World", {"ryanworld"}, "Helpful options for entities in the world.")
session_root = menu.list(menu.my_root(), "Session", {"ryansession"}, "Trolling options for the entire session.")
translate_root = menu.list(menu.my_root(), "Translate", {"ryantranslate"}, "Translate chat messages.")
settings_root = menu.list(menu.my_root(), "Settings", {"ryansettings"}, "Settings for Ryan's Menu.")


-- Self Menu --
self_office_money_root = menu.list(self_root, "CEO Office Money", {"ryanofficemoney"}, "Controls the amount of money in your CEO office.")

-- -- CEO Office Money
office_money_notice = false
menu.action(self_office_money_root, "25% Full", {"ryanofficemoney25"}, "Makes the office 25% full with money.", function()
    do_office_money(5000000)
end)
menu.action(self_office_money_root, "50% Full", {"ryanofficemoney50"}, "Makes the office 50% full with money.", function()
    do_office_money(10000000)
end)
menu.action(self_office_money_root, "100% Full", {"ryanofficemoney100"}, "Makes the office 100% full with money.", function()
    do_office_money(20000000)
end)

-- -- MC Clubhouse Clutter
mc_clutter_notice = false
menu.action(self_root, "M.C. Clutter", {"ryanmcclutter"}, "Adds drugs, money, and other clutter to your M.C. clubhouse.", function()
    do_mc_clutter()
end)

-- World Menu --
world_teleport_root = menu.list(world_root, "Teleport To...", {"ryanteleport"}, "Useful presets to teleport to.")
world_closest_vehicle_root = menu.list(world_root, "Closest Vehicle...", {"ryanclosestvehicle"}, "Useful options for nearby vehicles.")

world_action_figures_root = menu.list(world_teleport_root, "Action Figures...", {"ryanactionfigures"}, "Every action figure in the game.")
world_signal_jammers_root = menu.list(world_teleport_root, "Signal Jammers...", {"ryansignaljammers"}, "Every signal jammer in the game.")
world_playing_cards_root = menu.list(world_teleport_root, "Playing Cards...", {"ryanplayingcards"}, "Every playing card in the game.")

-- -- Action Figures
for i = 1, #ACTION_FIGURES do
    menu.action(world_action_figures_root, "Action Figure " .. i, {"ryanactionfigure" .. i}, "Teleports to action figure #" .. i, function()
        teleport_to(ACTION_FIGURES[i][1], ACTION_FIGURES[i][2], ACTION_FIGURES[i][3])
    end)
end

-- -- Signal Jammers
for i = 1, #SIGNAL_JAMMERS do
    menu.action(world_signal_jammers_root, "Signal Jammer " .. i, {"ryansignaljammer" .. i}, "Teleports to signal jammer #" .. i, function()
        teleport_vehicle_to(SIGNAL_JAMMERS[i][1], SIGNAL_JAMMERS[i][2], SIGNAL_JAMMERS[i][3])
    end)
end

-- -- Playing Cards
for i = 1, #PLAYING_CARDS do
    menu.action(world_playing_cards_root, "Playing Card " .. i, {"ryanplayingcard" .. i}, "Teleports to playing card #" .. i, function()
        teleport_vehicle_to(PLAYING_CARDS[i][1], PLAYING_CARDS[i][2], PLAYING_CARDS[i][3])
    end)
end

-- -- Enter Closest Vehicle
menu.action(world_closest_vehicle_root, "Drive", {"ryandrivevehicle"}, "Teleports into the closest vehicle.", function()
    local closest_vehicle = get_closest_vehicle(ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true))
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(closest_vehicle, -1)
    
    if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, -1) then
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), closest_vehicle, -1)
        util.toast("Teleported into the closest vehicle.")
    else
        if PED.GET_PED_TYPE(ped) < 4 then
            entities.delete(driver)
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), closest_vehicle, -1)
            util.toast("Teleported into the closest vehicle.")
        elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(closest_vehicle) then
            for i=0, 10 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, i) then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), closest_vehicle, i)
                end
            end
            util.toast("Teleported into the closest vehicle.")
        else
            util.toast("No nearby vehicles found.")
        end
    end
end)

-- -- Downgrade Closest Vehicle
menu.action(world_closest_vehicle_root, "Downgrade", {"ryandowngradevehicle"}, "Downgrades the closest vehicle.", function()
    local closest_vehicle = get_closest_vehicle(ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true))
    vehicle_control_loop(closest_vehicle)
    VEHICLE.SET_VEHICLE_MOD_KIT(closest_vehicle, 0)
    for i=0, 50 do
        VEHICLE.SET_VEHICLE_MOD(closest_vehicle, i, -1, false)
    end
    util.toast("Downgraded the nearest car!")
end)


-- Translate Menu --
translate_message = ""
menu.text_input(translate_root, "Message", {"ryantranslatemessage"}, "The message to send in chat.", function(value)
    translate_message = value
end, "")

-- -- Send Message
translate_send_root = menu.list(translate_root, "Send...", {"ryantranslatesend"}, "Translate and send the message.")
menu.action(translate_send_root, "Spanish", {"ryantranslatespanish"}, "Translate to Spanish.", function()
    util.toast("Translating message to Spanish...")
    send_translated(translate_message, "ES", false)
end)
menu.action(translate_send_root, "Russian", {"ryantranslaterussian"}, "Translate to Russian.", function()
    util.toast("Translating message to Russian...")
    send_translated(translate_message, "RU", true)
end)
menu.action(translate_send_root, "Russian (Cyrillic)", {"ryantranslatecyrillic"}, "Translate to Russian (Cyrillic).", function()
    util.toast("Translating message to Russian (Cyrillic)...")
    send_translated(translate_message, "RU", false)
end)
menu.action(translate_send_root, "French", {"ryantranslatefrench"}, "Translate to French.", function()
    util.toast("Translating message to French...")
    send_translated(translate_message, "FR", false)
end)
menu.action(translate_send_root, "German", {"ryantranslategerman"}, "Translate to German.", function()
    util.toast("Translating message to German...")
    send_translated(translate_message, "DE", false)
end)
menu.action(translate_send_root, "Italian", {"ryantranslateitalian"}, "Translate to Italian.", function()
    util.toast("Translating message to Italian...")
    send_translated(translate_message, "IT", false)
end)


-- Session Menu --
session_spam_chat_root = menu.list(session_root, "Spam Chat...", {"ryanspam"}, "Spams the chat with a message from all players.")
session_trolling_root = menu.list(session_root, "Trolling...", {"ryantrolling"}, "Trolling options on all players.")
session_nuke_attack_root = menu.list(session_root, "Nuke...", {"ryannuke"}, "Plays a siren, timer, and bomb with additional earrape.")
session_dox_root = menu.list(session_root, "Dox...", {"ryandox"}, "Shares information players probably want private.")

-- -- Spam Chat
spam_chat_all_players = true
spam_chat_delay = 100
spam_chat_message = "Get Ryan's Menu for Stand!"
spam_chat_last = 0

menu.toggle(session_spam_chat_root, "All Players Spam", {"ryanspamall"}, "If enabled, all players spam. Otherwise your real name is used.", function(value)
    spam_chat_all_players = value
end, true)
menu.slider(session_spam_chat_root, "Delay Between Messages", {"ryanspamdelay"}, "Delay in milliseconds between each message.", 0, 1000, 25, 25, function(value)
    spam_chat_delay = value
end)
menu.text_input(session_spam_chat_root, "Message", {"ryanspammessage"}, "The message that will be spammed.", function(value)
    spam_chat_message = value
end, "Get Ryan's Menu for Stand!")
menu.toggle_loop(session_spam_chat_root, "Spam: Loop", {"ryanspamloop"}, "If enabled, the message will be spammed continuously.", function()
    if util.current_time_millis() - spam_chat_last >= spam_chat_delay * 32 then
        spam_chat(spam_chat_message, spam_chat_all_players, spam_chat_delay, 0)
        spam_chat_last = util.current_time_millis()
    end
end, false)
menu.action(session_spam_chat_root, "Spam: Once", {"ryanspamonce"}, "Spams the message once.", function()
    local spam_chat_type = "other players' names"
    if spam_chat_all_players then
        spam_chat_type = "your real name"
    end
    util.toast("Spamming chat using " .. spam_chat_type .. ".")
    spam_chat(spam_chat_message, spam_chat_all_players, spam_chat_delay, 0)
end)

-- -- Vehicle
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
    run_all({"enemyclone{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Chop", {"ryanattackallchop"}, "Sends Chop to attack all players.", function()
    util.toast("Sending Chop after all players...")
    run_all({"sendchop{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Police", {"ryanattackallpolice"}, "Sends the law to attack all players.", function()
    util.toast("Sending a police car after all players...")
    run_all({"sendpolicecar{name}"}, trolling_include_modders, trolling_watch_time)
end)

menu.divider(session_trolling_root, "Vehicle")
menu.action(session_trolling_root, "Tow", {"ryantowall"}, "Sends a tow truck to all players.", function()
    util.toast("Towing all players...")
    run_all({"towtruck{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Catapult", {"ryancatapultall"}, "Catapults everyone's vehicles.", function()
    util.toast("Catapulting all players...")
    takeover_vehicle_all(function(vehicle)
        if VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) then
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 9999, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
        end
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Burst Tires", {"ryanbursttiresall"}, "Bursts everyone's tires.", function()
    util.toast("Bursting all tires...")
    takeover_vehicle_all(function(vehicle)
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true)
		for i=0, 7 do
			VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
		end
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Kill Engine", {"ryankillengineall"}, "Kills everyone's engine.", function()
    util.toast("Killing all engines...")
    takeover_vehicle_all(function(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
    end, trolling_include_modders, trolling_watch_time)
end)

-- -- Nuke
nuke_spam_enabled = false

menu.toggle(session_nuke_attack_root, "Spam Chat", {"ryannukespam"}, "If enabled, triggers Spam Chat once upon impact.", function(value)
    nuke_spam_enabled = value
end)
menu.action(session_nuke_attack_root, "Start Nuke", {"ryannukestart"}, "Starts the nuke.", function()
    util.toast("Nuke incoming.")
    play_all("Air_Defences_Activated", "DLC_sum20_Business_Battle_AC_Sounds", 3000)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 1000)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 1000)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 500)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 500)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 125)
    explode_all(EARRAPE_FLASH, 0)
    explode_all(EARRAPE_FLASH, 150)
    explode_all(EARRAPE_BED, 0)
    explode_all(EARRAPE_NONE, 0)
    if nuke_spam_enabled then
        spam_chat(spam_chat_message, true, spam_chat_delay, 0)
    end
end)

-- -- Dox Players
menu.action(session_dox_root, "Richest & Poorest", {"ryanrichest"}, "Shares the name of the richest and poorest players.", function()
    get_players_by_money()
end)
menu.action(session_dox_root, "K/D Ratio", {"ryankd"}, "Shares the name of the highest and lowest K/D players.", function()
    get_players_by_kd()
end)
menu.action(session_dox_root, "Godmode", {"ryangodmode"}, "Shares the name of the players in godmode.", function()
    get_players_by_godmode()
end)
menu.action(session_dox_root, "Off Radar", {"ryanoffradar"}, "Shares the name of the players off the radar.", function()
    get_players_by_offradar()
end)
menu.action(session_dox_root, "Oppressor", {"ryanoppressor"}, "Shares the name of the players in Oppressors.", function()
    get_players_by_oppressor2()
end)

-- -- No Godmode
menu.toggle_loop(session_root, "No Godmode", {"ryannogodmodeall"}, "Removes godmode from all Kiddions users in the session.", function()
    for k, player_id in pairs(players.list(false, true, true)) do
        remove_godmode(player_id)
    end
end, false)

-- Player Options --
function setup_player(player_id)
    local player_root = menu.player_root(player_id)
    menu.divider(player_root, "Ryan's Menu")
    local player_trolling_root = menu.list(player_root, "Trolling...", {"ryantrolling"}, "Options that players may not like.")

    -- -- Text & Kick
    local text_kick_root = menu.list(player_trolling_root, "Text & Kick...", {"ryantextkick"}, "Kicks the player after spamming them with texts.")
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
        local player = players.get_name(player_id)
        util.toast("Spamming " .. player .. " with texts...")
        menu.trigger_commands("smsrandomsender" .. player .. " on")
        menu.trigger_commands("smstext" .. player .. " " .. text_kick_message)
        menu.trigger_commands("smsspam" .. player .. " on")
        util.yield(text_kick_duration)
        util.toast("Kicking " .. player .. "!")
        if text_kick_block_joins then
            block_joins(player)
        end
        menu.trigger_commands("kick" .. player)
        menu.trigger_commands("breakup" .. player)
        menu.trigger_commands("players")
    end)

    -- -- No Godmode
    local remove_godmode_notice = 0
    menu.toggle_loop(player_trolling_root, "No Godmode", {"ryannogodmode"}, "Removes godmode from Kiddions users and their vehicles.", function()
        remove_godmode(player_id, true)
        if util.current_time_millis() - remove_godmode_notice >= 10000 then
            util.toast("Still removing godmode from " .. players.get_name(player_id) .. ".")
            remove_godmode_notice = util.current_time_millis()
        end
    end, false)

    -- -- Downgrade Vehicle
    menu.action(player_trolling_root, "Downgrade Vehicle", {"ryandowngrade"}, "Downgrades the car they are in.", function()
        takeover_vehicle(function(vehicle)
            VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
            for i=0, 50 do
                VEHICLE.SET_VEHICLE_MOD(vehicle, i, -1, false)
            end
        end, player_id, 0)
        util.toast("Downgraded " .. players.get_name(player_id) .. "'s car!")
    end)

    -- -- Divorce Kick
    menu.action(player_root, "Divorce", {"ryandivorce"}, "Kicks the player, then blocks future joins by them.", function()
        local player = players.get_name(player_id)
        block_joins(player)
        menu.trigger_commands("kick" .. player)
        menu.trigger_commands("breakup" .. player)
        menu.trigger_commands("players")
    end)
end


-- Settings Menu --
menu.action(settings_root, "Version: " .. version, {}, "The currently installed version.", function() end)
menu.hyperlink(settings_root, "Get Latest Version", "https://github.com/RyanGarber/Ryans-Menu/raw/main/Ryan's Menu.lua", "Opens the latest version of the menu for downloading.")


-- Initialize --
players.on_join(function(player_id) setup_player(player_id) end)
players.dispatch_on_join()

util.keep_running()