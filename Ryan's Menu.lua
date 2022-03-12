version = "0.2.3"


-- Requirements --
require("natives-1640181023")


-- Check for Updates --
util.toast("Welcome to Ryan's Menu v" .. version ..". Checking for updates...")
async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/VERSION", function(latest_version)
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


-- Helper Functions --
function get_closest_vehicle(entity)
    local location = ENTITY.GET_ENTITY_COORDS(entity, true)
    local vehicles = entities.get_all_vehicles_as_handles()
    local closest_distance = 1000000
    local closest_vehicle = 0
    for k, vehicle in pairs(vehicles) do
        if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false) then
            local vehicle_location = ENTITY.GET_ENTITY_COORDS(vehicle, true)
            local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(location['x'], location['y'], location['z'], vehicle_location['x'], vehicle_location['y'], vehicle_location['z'], true)
            if distance < closest_distance then
                closest_distance = distance
                closest_vehicle = vehicle
            end
        end
    end
    return closest_vehicle
end

function spam_chat(message, all_players, time_between, wait_for)
    local sent = 0
    while sent < 32 do
        if all_players then
            for k, player in pairs(players.list(true, true, true)) do
                local name = PLAYER.GET_PLAYER_NAME(player)
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
        player_ped = PLAYER.GET_PLAYER_PED(i)
        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound, player_ped, sound_group, true, 20)
    end
    util.yield(wait_for)
end

EARRAPE_NONE = 0
EARRAPE_BED = 1
EARRAPE_FLASH = 2
function explode_all(earrape_type, wait_for)
    for i=0, 31, 1 do
        player_ped = PLAYER.GET_PLAYER_PED(i)
        position = ENTITY.GET_ENTITY_COORDS(player_ped)
        FIRE.ADD_EXPLOSION(position.x, position.y, position.z, 0, 100, true, false, 150, false)
        if earrape_type == EARRAPE_BED then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "Bed", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
        end
        if earrape_type == EARRAPE_FLASH then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
        end
    end
    util.yield(wait_for)
end

function teleport_to(x, y, z)
    util.toast("Teleporting...")
    local player = PLAYER.PLAYER_PED_ID()
    ENTITY.SET_ENTITY_COORDS(player, x, y, z)
end

function teleport_vehicle_to(x, y, z)
    util.toast("Teleporting...")
    local player = PLAYER.PLAYER_PED_ID()
    if PED.IS_PED_IN_ANY_VEHICLE(player, true) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player, false)
        ENTITY.SET_ENTITY_COORDS(vehicle, x, y, z)
    else
        ENTITY.SET_ENTITY_COORDS(player, x, y, z)
    end
end

function run_all(commands)
    for k, player in pairs(players.list(true, true, true)) do
        local name = PLAYER.GET_PLAYER_NAME(player)
        for i = 1, #commands do
            menu.trigger_commands(commands[i]:gsub("{name}", name))
        end
    end
end

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

function send_translated(message, language)
    async_http.init("api-free.deepl.com", "/v2/translate?auth_key=5b295d7c-ee3a-e158-caaa-6ec2eeeed90f:fx&text=" .. message .. "&target_lang=" .. language, function(result)
        result = result:match("\"text\":\"(.+)\"")
        for from, to in pairs(RUSSIAN_ALPHABET) do
            result = result:gsub(from, to)
        end
        chat.send_message(result, false, true, true)
    end, function()
        util.toast("Failed to translate message.")
    end)
    async_http.dispatch()
end


-- Main Menu --
world_root = menu.list(menu.my_root(), "World", {"ryanworld"}, "Helpful options for entities in the world.")
session_root = menu.list(menu.my_root(), "Session", {"ryansession"}, "Trolling options for the entire session.")
translate_root = menu.list(menu.my_root(), "Translate", {"ryantranslate"}, "Translate chat messages.")
settings_root = menu.list(menu.my_root(), "Settings", {"ryansettings"}, "Settings for Ryan's Menu.")


-- World Menu --
world_teleport_root = menu.list(world_root, "Teleport To...", {"ryanteleport"}, "Useful presets to teleport to.")
world_action_figures_root = menu.list(world_teleport_root, "Action Figures...", {"ryanactionfigures"}, "Every action figure in the game.")
world_signal_jammers_root = menu.list(world_teleport_root, "Signal Jammers...", {"ryansignaljammers"}, "Every signal jammer in the game.")
world_playing_cards_root = menu.list(world_teleport_root, "Playing Cards...", {"ryanplayingcards"}, "Every playing card in the game.")


-- Translate Menu --
translate_message = ""
menu.text_input(translate_root, "Message", {"ryantranslatemessage"}, "The message to send in chat.", function(value)
    translate_message = value
end, "")

-- -- Send Message
translate_send_root = menu.list(translate_root, "Send...", {"ryantranslatesend"}, "Translate and send the message.")
menu.action(translate_send_root, "Spanish", {"ryantranslatespanish"}, "Translate to Spanish.", function()
    util.toast("Translating message to Spanish...")
    send_translated(translate_message, "ES")
end)
menu.action(translate_send_root, "Russian", {"ryantranslaterussian"}, "Translate to Russian.", function()
    util.toast("Translating message to Russian...")
    send_translated(translate_message, "RU")
end)
menu.action(translate_send_root, "French", {"ryantranslatefrench"}, "Translate to French.", function()
    util.toast("Translating message to French...")
    send_translated(translate_message, "FR")
end)
menu.action(translate_send_root, "German", {"ryantranslategerman"}, "Translate to German.", function()
    util.toast("Translating message to German...")
    send_translated(translate_message, "DE")
end)

-- -- Action Figures
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
for i = 1, #ACTION_FIGURES do
    menu.action(world_action_figures_root, "Action Figure " .. i, {"ryanactionfigure" .. i}, "Teleports to action figure #" .. i, function()
        teleport_to(ACTION_FIGURES[i][1], ACTION_FIGURES[i][2], ACTION_FIGURES[i][3])
    end)
end

-- -- Signal Jammers
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
for i = 1, #SIGNAL_JAMMERS do
    menu.action(world_signal_jammers_root, "Signal Jammer " .. i, {"ryansignaljammer" .. i}, "Teleports to signal jammer #" .. i, function()
        teleport_vehicle_to(SIGNAL_JAMMERS[i][1], SIGNAL_JAMMERS[i][2], SIGNAL_JAMMERS[i][3])
    end)
end

-- -- Playing Cards
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
for i = 1, #PLAYING_CARDS do
    menu.action(world_playing_cards_root, "Playing Card " .. i, {"ryanplayingcard" .. i}, "Teleports to playing card #" .. i, function()
        teleport_vehicle_to(PLAYING_CARDS[i][1], PLAYING_CARDS[i][2], PLAYING_CARDS[i][3])
    end)
end

-- -- Into Closest Vehicle
menu.action(world_root, "Enter Closest Vehicle", {"ryanclosestvehicle"}, "Teleports into the closest vehicle.", function()
    local closest_vehicle = get_closest_vehicle(PLAYER.PLAYER_PED_ID())
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
        --menu.run_commands("copyvehicler")
    end
end)


-- Session Menu --
session_spam_chat_root = menu.list(session_root, "Spam Chat...", {"ryanspam"}, "Spams the chat with a message from all players.")
session_nuke_attack_root = menu.list(session_root, "Nuke...", {"ryannuke"}, "Plays a siren, timer, and bomb with additional earrape.")
session_trolling_root = menu.list(session_root, "Trolling...", {"ryantrolling"}, "Trolling options on all players.")

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

-- -- Send Attacker
session_send_attacker_root = menu.list(session_trolling_root, "Send Attacker...", {"ryanattackall"}, "Attackers to send to all players.")
menu.action(session_send_attacker_root, "Random", {"ryanattackallrandom"}, "Sends random NPCs to attack all players.", function()
    run_all({"attacker{name}"})
end)
menu.action(session_send_attacker_root, "Clone", {"ryanattackallclone"}, "Sends an angry clone to attack all players.", function()
    run_all({"enemyclone{name}"})
end)
menu.action(session_send_attacker_root, "Chop", {"ryanattackallchop"}, "Sends Chop to attack all players.", function()
    run_all({"sendchop{name}"})
end)
menu.action(session_send_attacker_root, "Police", {"ryanattackallpolice"}, "Sends the law to attack all players.", function()
    run_all({"sendpolicecar{name}"})
end)


-- -- Send Vehicle
menu.action(session_trolling_root, "Send Go-Karts", {"ryangokartall"}, "Sends Go-Karts to annoy all players.", function()
    run_all({"sendgokart{name}", "sendbandito{name}"})
end)
menu.action(session_trolling_root, "Ram", {"ryanramall"}, "Sends a phantom wedge into all players' heads.", function()
    run_all({"ram{name}"})
end)
menu.action(session_trolling_root, "Tow", {"ryantowall"}, "Sends a tow truck to all players.", function()
    run_all({"towtruck{name}"})
end)


-- Player Options --
function setup_player(player_id)
    local player_root = menu.player_root(player_id)
    
    -- -- Divorce Kick
    menu.divider(player_root, "Ryan's Menu")
    menu.action(player_root, "Divorce", {"ryandivorce"}, "Kicks the player, then blocks future joins by them.", function()
        local player = players.get_name(player_id)
        
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
        
        menu.trigger_commands("players")
        menu.trigger_commands("breakup" .. player)
        menu.trigger_commands("kick" .. player)
    end)
end

-- Settings Menu --

-- -- Check for Updates
menu.action(settings_root, "Version: " .. version, {}, "The currently installed version.", function() end)
menu.hyperlink(settings_root, "Get Latest Version", "https://github.com/RyanGarber/Ryans-Menu/raw/main/Ryan's Menu.lua", "Opens the latest version of the menu for downloading.")


-- Initialize --
players.on_join(function(player_id)
    setup_player(player_id)
end)
players.dispatch_on_join()

util.keep_running()