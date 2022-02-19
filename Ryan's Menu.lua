version = "0.2.0"

-- Requirements
util.keep_running()
require("natives-1640181023")

-- Check for Updates
util.toast("Welcome to Ryan's Menu v" .. version ..". Checking for updates...")
async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/VERSION", function(latest_version)
    if latest_version ~= version then
        util.toast("The version you are using is outdated! Press Get Latest Version to get v" .. latest_version .. ".")
        menu.trigger_commands("ryansettings")
    else
        util.toast("You're up to date! Enjoy :)")
    end
end, function()
    util.toast("Failed to get the latest version. Go to Settings and press Update to check for a new version.")
end)
async_http.dispatch()

-- Helper Functions
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
        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound, player_ped, sound_group, true, true)
    end
    util.yield(wait_for)
end

function explode_all(earrape_type, wait_for)
    for i=0, 31, 1 do
        player_ped = PLAYER.GET_PLAYER_PED(i)
        position = ENTITY.GET_ENTITY_COORDS(player_ped)
        FIRE.ADD_EXPLOSION(position.x, position.y, position.z, 0, 100, true, false, 150, false)
        if earrape_type == 1 then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "Bed", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
        end
        if earrape_type == 2 then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", position.x, position.y, position.z, "WastedSounds", true, 999999999, true)
        end
    end
    util.yield(wait_for)
end

function teleport_to_blip(blip)
    position = HUD.GET_BLIP_INFO_ID_COORD(blip)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), position.x, position.y, position.z, false, false, false)
    util.toast(HUD.GET_BLIP_INFO_ID_DISPLAY(blip))
end


-- Main Menu
world_root = menu.list(menu.my_root(), "World", {"ryanworld"}, "Helpful options for entities in the world.")
session_root = menu.list(menu.my_root(), "Session", {"ryansession"}, "Trolling options for the entire session.")
settings_root = menu.list(menu.my_root(), "Settings", {"ryansettings"}, "Settings for Ryan's Menu.")

-- World Menu

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
    end
end)

-- Session Menu
session_spam_chat_root = menu.list(session_root, "Spam Chat...", {"ryanspam"}, "Spams the chat with a message from all players.")
session_terrorist_attack_root = menu.list(session_root, "Terrorist Attack...", {"ryanterrorist"}, "Plays a siren, timer, and bomb with additional earrape.")

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

-- -- Terrorist Attack
terrorist_spam_enabled = false

menu.toggle(session_terrorist_attack_root, "Spam Chat", {"ryanterroristspam"}, "If enabled, triggers Spam Chat once upon impact.", function(value)
    terrorist_spam_enabled = value
end)
menu.action(session_terrorist_attack_root, "Start Attack", {"ryanterroriststart"}, "Starts the attack.", function()
    util.toast("Terrorist attack incoming.")
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
    explode_all(2, 0)
    explode_all(2, 150)
    explode_all(1, 0)
    explode_all(0, 0)
    if terrorist_spam_enabled then
        spam_chat(spam_chat_message, true, spam_chat_delay, 0)
    end
end)

-- Settings Menu

-- -- Check for Updates
menu.action(settings_root, "Version: " .. version, {}, "The currently installed version.", function() end)
menu.hyperlink(settings_root, "Get Latest Version", "https://github.com/RyanGarber/Ryans-Menu/raw/main/Ryan's Menu.lua", "Opens the latest version of the menu for downloading.")