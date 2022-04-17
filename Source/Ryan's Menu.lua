VERSION = "0.6.10"
MANIFEST = {
    lib = {"Audio.lua", "Basics.lua", "Entity.lua", "Globals.lua", "Player.lua", "PTFX.lua", "Session.lua", "Stats.lua", "Vector.lua", "Vehicle.lua"},
    resources = {"Crosshair.png"}
}


-- Requirements --
notified_of_requirements = false

function exists(name) return filesystem.exists(filesystem.scripts_dir() .. name) end
while not exists("lib\\natives-1640181023.lua") or not exists("lib\\natives-1627063482.lua") do
    if not notified_of_requirements then
        local ref = menu.ref_by_path("Stand>Lua Scripts>Repository>WiriScript")
        menu.focus(ref)
        notified_of_requirements = true
    end

    util.toast("Ryan's Menu requires WiriScript and LanceScript to function. Please enable them to continue.")
    util.yield(2000)
end

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

require("natives-1640181023")
basics_request_model(2628187989)


-- Check for Updates --
async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/MANIFEST", function(manifest)
    latest_version = manifest:sub(1, manifest:find("\n") - 1)
    if latest_version ~= VERSION then
        basics_show_text_message(6, "v" .. VERSION, "This version is outdated. Press Get Latest Version to get v" .. latest_version .. ".")
        menu.trigger_commands("ryansettings")
    else
        basics_show_text_message(49, "v" .. VERSION, VERSION:find("6.9") and "nice" or "You're up to date. Enjoy!")
    end
    audio_play_from_entity(player_get_ped(), "GTAO_FM_Events_Soundset", "Object_Dropped_Remote")
end, function()
    basics_show_text_message(6, "v" .. VERSION, "Failed to get the latest version. Go to Settings to check manually.")
end)
async_http.dispatch()


-- Main Menu --
self_root = menu.list(menu.my_root(), "Self", {"ryanself"}, "Helpful options for yourself.")
world_root = menu.list(menu.my_root(), "World", {"ryanworld"}, "Helpful options for entities in the world.")
session_root = menu.list(menu.my_root(), "Session", {"ryansession"}, "Trolling options for the entire session.")
stats_root = menu.list(menu.my_root(), "Stats", {"ryanstats"}, "Common stats you may want to edit.")
chat_root = menu.list(menu.my_root(), "Chat", {"ryanchat"}, "Send special chat messages.")
settings_root = menu.list(menu.my_root(), "Settings", {"ryansettings"}, "Settings for Ryan's Menu.")


--lights = {""}
--test = menu.list(menu.my_root(), "Test", {"ryantest"}, "")


-- Self Menu --
self_ptfx_root = menu.list(self_root, "PTFX...", {"ryanptfx"}, "Special FX options.")
self_fire_root = menu.list(self_root, "Fire...", {"ryanfire"}, "An enhanced LanceScript burning man.")
self_forcefield_root = menu.list(self_root, "Forcefield...", {"ryanforcefield"}, "An enhanced WiriScript forcefield.")

-- -- PTFX
ptfx_color = {r = 1.0, g = 1.0, b = 1.0}
ptfx_disable = false

self_ptfx_body_root = menu.list(self_ptfx_root, "Body...", {"ryanptfxbody"}, "Special FX on your body other players can see.")
self_ptfx_weapon_root = menu.list(self_ptfx_root, "Weapon...", {"ryanptfxweapon"}, "Special FX on your weapon other players can see.")
self_ptfx_vehicle_root = menu.list(self_ptfx_root, "Vehicle...", {"ryanptfxvehicle"}, "Special FX on your vehicle other players can see.")
self_ptfx_pointing_root = menu.list(self_ptfx_root, "Pointing...", {"ryanptfxpointing"}, "Special FX when pointing other players can see.")

menu.divider(self_ptfx_root, "Options")
menu.colour(self_ptfx_root, "Color", {"ryanptfxcolor"}, "Some PTFX options allow for custom colors.", 1.0, 1.0, 1.0, 1.0, false, function(color)
    ptfx_color.r = color.r
    ptfx_color.g = color.g
    ptfx_color.b = color.b
end)
menu.toggle(self_ptfx_root, "Disable", {"ryanptfxoff"}, "Disables PTFX but keeps your settings.", function(value)
    ptfx_disable = value
end)

-- -- Body PTFX
self_ptfx_body_head_root = menu.list(self_ptfx_body_root, "Head...", {"ryanptfxhead"}, "Special FX on your head.")
self_ptfx_body_hands_root = menu.list(self_ptfx_body_root, "Hands...", {"ryanptfxhands"}, "Special FX on your hands.")
self_ptfx_body_feet_root = menu.list(self_ptfx_body_root, "Feet...", {"ryanptfxfeet"}, "Special FX on your feet.")

ptfx_create_list(self_ptfx_body_head_root, function(ptfx)
    ptfx_play_on_entity_bones(player_get_ped(), PlayerBone.Head, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

ptfx_create_list(self_ptfx_body_hands_root, function(ptfx)
    ptfx_play_on_entity_bones(player_get_ped(), PlayerBone.Hands, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

ptfx_create_list(self_ptfx_body_feet_root, function(ptfx)
    ptfx_play_on_entity_bones(player_get_ped(), PlayerBone.Feet, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

-- -- Vehicle PTFX
self_ptfx_vehicle_wheels_root = menu.list(self_ptfx_vehicle_root, "Wheels...", {"ryanptfxwheels"}, "Special FX on the wheels of your vehicle.")
self_ptfx_vehicle_exhaust_root = menu.list(self_ptfx_vehicle_root, "Exhaust...", {"ryanptfxexhaust"}, "Speicla FX on the exhaust of your vehicle.")

ptfx_create_list(self_ptfx_vehicle_wheels_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(), true)
    if vehicle ~= NULL then
        ptfx_play_on_entity_bones(vehicle, VehicleBone.Wheels, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

ptfx_create_list(self_ptfx_vehicle_exhaust_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(), true)
    if vehicle ~= NULL then
        ptfx_play_on_entity_bones(vehicle, VehicleBone.Exhaust, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Weapon PTFX
self_ptfx_weapon_aiming_root = menu.list(self_ptfx_weapon_root, "Aiming...", {"ryanptfxaiming"}, "Special FX when aiming at a spot.")
self_ptfx_weapon_muzzle_root = menu.list(self_ptfx_weapon_root, "Muzzle...", {"ryanptfxmuzzle"}, "Special FX on the end of your weapon's barrel.")
self_ptfx_weapon_muzzle_flash_root = menu.list(self_ptfx_weapon_root, "Muzzle Flash...", {"ryanptfxmuzzleflash"}, "Special FX on the end of your weapon's barrel when firing.")
self_ptfx_weapon_impact_root = menu.list(self_ptfx_weapon_root, "Impact...", {"ryanptfximpact"}, "Special FX at the impact of your bullets.")

ptfx_create_list(self_ptfx_weapon_aiming_root, function(ptfx)
    if ptfx_disable then return end
    if CAM.IS_AIM_CAM_ACTIVE() then
        local raycast = basics_do_raycast(500.0)
        if raycast.did_hit then
            ptfx_play_at_coords(raycast.hit_coords, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

ptfx_create_list(self_ptfx_weapon_muzzle_root, function(ptfx)
    if ptfx_disable then return end
    local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(player_get_ped())
    if weapon ~= NULL then
        ptfx_play_at_entity_bone_coords(weapon, WeaponBone.Muzzle, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

ptfx_create_list(self_ptfx_weapon_muzzle_flash_root, function(ptfx)
    if ptfx_disable then return end
    local player_ped = player_get_ped()
    if PED.IS_PED_SHOOTING(player_ped) then
        local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(player_ped)
        if weapon ~= NULL then
            ptfx_play_at_entity_bone_coords(weapon, WeaponBone.Muzzle, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

ptfx_create_list(self_ptfx_weapon_impact_root, function(ptfx)
    if ptfx_disable then return end
    local impact_ptr = memory.alloc()
    if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(player_get_ped(), impact_ptr) then
        ptfx_play_at_coords(memory.read_vector3(impact_ptr), ptfx[2], ptfx[3], ptfx_color)
        memory.free(impact_ptr)
    end
end)

-- -- Pointing PTFX
self_ptfx_pointing_finger_root = menu.list(self_ptfx_pointing_root, "Finger...", {"ryanptfxpointingfinger"}, "Special FX on your left finger.")
self_ptfx_pointing_crosshair_root = menu.list(self_ptfx_pointing_root, "Crosshair...", {"ryanptfxpointingcrosshair"}, "Special FX on your crosshair.")
self_ptfx_pointing_god_finger_root = menu.list(self_ptfx_pointing_root, "Target...", {"ryanptfxpointingtarget"}, "Special FX on your target when using God Finger.")

ptfx_create_list(self_ptfx_pointing_finger_root, function(ptfx)
    if ptfx_disable then return end
    if memory.read_int(memory.script_global(4516656 + 930)) == 3 then
        ptfx_play_on_entity_bones(player_get_ped(), PlayerBone.Pointer, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

ptfx_create_list(self_ptfx_pointing_crosshair_root, function(ptfx)
    if ptfx_disable then return end
    if player_is_pointing then
        local raycast = basics_do_raycast(1000.0)
        if raycast.did_hit then
            ptfx_play_at_coords(raycast.hit_coords, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

ptfx_create_list(self_ptfx_pointing_god_finger_root, function(ptfx)
    if ptfx_disable then return end
    if god_finger_target ~= nil then
        ptfx_play_at_coords(god_finger_target, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Forcefield
forcefield_mode = "Off"
forcefield_size = 10
forcefield_force = 1

for _, mode in pairs(ForcefieldMode) do
    menu.toggle(self_forcefield_root, mode, {"ryanforcefield" .. mode:lower()}, "", function(value)
        if value then
            menu.trigger_commands("ryanforcefield" .. forcefield_mode:lower() .. " off")
            forcefield_mode = mode
        end
    end, mode == "Off")
end

menu.divider(self_forcefield_root, "Options")
menu.slider(self_forcefield_root, "Size", {"ryanforcefieldsize"}, "Diameter of the forcefield sphere.", 10, 250, 10, 10, function(value)
    forcefield_size = value
end)
menu.slider(self_forcefield_root, "Force", {"ryanforcefieldforce"}, "Force applied by the forcefield.", 1, 100, 1, 1, function(value)
    forcefield_force = value
end)

entities_destroyed = {}
util.create_tick_handler(function()
    if forcefield_mode == "Push" then
        local player_ped = player_get_ped()
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
		local nearby = entity_get_all_nearby(player_coords, forcefield_size, NearbyEntities.All)
		for _, entity in pairs(nearby) do
			local entity_coords = ENTITY.GET_ENTITY_COORDS(entity)
			local force = vector_normalize(vector_subtract(entity_coords, player_coords))
            force = vector_multiply(force, forcefield_force)
			if ENTITY.IS_ENTITY_A_PED(entity) then
				if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
					entity_request_control(entity)
					PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
					ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
				end
			elseif entity ~= entities.get_user_vehicle_as_handle() then
				entity_request_control(entity)
				ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
			end
		end
        entities_destroyed = {}
    elseif forcefield_mode == "Destroy" then
        ENTITY.SET_ENTITY_PROOFS(player_get_ped(), false, false, true, false, false, false, 1, false)

        local player_ped = player_get_ped()
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        local player_vehicle = entities.get_user_vehicle_as_handle()

        local nearby = entity_get_all_nearby(player_coords, 200, NearbyEntities.All)
        for _, entity in pairs(nearby) do
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
        ENTITY.SET_ENTITY_PROOFS(player_get_ped(), false, false, false, false, false, false, 1, false)
        entities_destroyed = {}
    end
    return true
end)

-- -- Fire
fire_finger_mode = "Off"
self_fire_finger_root = menu.list(self_fire_root, "Finger...", {"ryanfirefinger"}, "Catches things on fire from a distance when pressing E.")
for _, mode in pairs(FireFingerMode) do
    menu.toggle(self_fire_finger_root, mode, {"ryanfirefinger" .. mode:lower()}, "", function(value)
        if value then
            menu.trigger_commands("ryanfirefinger" .. fire_finger_mode:lower() .. " off")
            fire_finger_mode = mode
        end
    end, mode == "Off")
end

menu.toggle(self_fire_root, "Body", {"ryanfirebody"}, "Sets yourself on fire visually.", function(value)
    if value then
        menu.trigger_commands("demigodmode on")
        FIRE.START_ENTITY_FIRE(player_get_ped())
    else
        menu.trigger_commands("demigodmode off")
        FIRE.STOP_ENTITY_FIRE(player_get_ped())
    end
end)

fire_finger_last_coords = {x = 0, y = 0, z = 0}
menu.toggle_loop(self_fire_root, "Touch", {"ryanfiretouch"}, "Catches things on fire when you touch them.", function(value)
    local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped())
    if vector_distance(coords, fire_finger_last_coords) > 1.5 then
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 3, 100.0, false, false, 1.0)
        fire_finger_last_coords = coords
    end
    util.yield(500)
end)

util.create_tick_handler(function()
    if fire_finger_mode == "Always" or (fire_finger_mode == "When Pointing" and player_is_pointing) then
        if PAD.IS_CONTROL_JUST_PRESSED(21, 86) then
            local raycast = basics_do_raycast(250.0)
            if raycast.did_hit then
                FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 3, 100.0, false, false, 0.0)
            end
        end
    end
end)

self_crosshair_root = menu.list(self_root, "Crosshair...", {"ryancrosshair"}, "Add an on-screen crosshair.")
crosshair_mode = "Off"

for _, mode in pairs(CrosshairMode) do
    menu.toggle(self_crosshair_root, mode, {"ryancrosshair" .. mode:lower()}, "", function(value)
        if value then
            menu.trigger_commands("ryancrosshair" .. crosshair_mode:lower() .. " off")
            crosshair_mode = mode
        end
    end, mode == "Off")
end

-- -- God Finger
player_is_pointing = false
god_finger_target = nil
menu.toggle_loop(self_root, "God Finger", {"ryangodfinger"}, "Pushes objects away when pointing at them.", function(value)
    if player_is_pointing then
        local raycast = basics_do_raycast(500.0, 2 + 8 + 16)
        memory.write_int(memory.script_global(4516656 + 935), NETWORK.GET_NETWORK_TIME())
        if raycast.did_hit and raycast.hit_entity ~= nil then
            god_finger_target = raycast.hit_coords
            ENTITY.SET_ENTITY_PROOFS(player_get_ped(), false, false, true, false, false, false, 1, false)
            FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 29, 25.0, false, true, 0.0, true)
            basics_esp_box(raycast.hit_entity)
        else
            god_finger_target = nil
            ENTITY.SET_ENTITY_PROOFS(player_get_ped(), false, false, false, false, false, false, 1, false)
        end
    else
        god_finger_target = nil
    end
end)

-- -- All Players Visible
menu.toggle_loop(self_root, "All Players Visible", {"ryannoinvisible"}, "Makes all invisible players visible again.", function()
    for _, player_id in pairs(players.list()) do
        ENTITY.SET_ENTITY_VISIBLE(player_get_ped(player_id), true, 0)
    end
end, false)

-- -- E-Brake
ebrake = false
menu.toggle(self_root, "E-Brake", {"ryanebrake"}, "Makes your car drift while holding Shift.", function(value)
    ebrake = value
end)
util.create_tick_handler(function()
    if ebrake then
        local player_ped = player_get_ped(players.user())
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) == player_ped then
            vehicle_set_no_grip(vehicle, PAD.IS_CONTROL_PRESSED(21, 21))
        end
    end
    util.yield()
end)


-- World Menu --
world_closest_vehicle_root = menu.list(world_root, "Closest Vehicle...", {"ryanclosestvehicle"}, "Useful options for nearby vehicles.")
world_collectibles_root = menu.list(world_root, "Collectibles...", {"ryancollectibles"}, "Useful presets to teleport to.")
world_all_vehicles_root = menu.list(world_root, "All Vehicles...", {"ryanallvehicles"}, "Control the vehicles around you.")
world_all_npcs_root = menu.list(world_root, "All NPCs...", {"ryanallnpcs"}, "Changes the action NPCs are currently performing.")

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

-- -- All Vehicles
all_vehicles_make_fast = false; vehicles_make_fast = {}
all_vehicles_make_slow = false; vehicles_make_slow = {}
all_vehicles_no_grip = false; vehicles_no_grip = {}
all_vehicles_burst_tires = false; vehicles_burst_tires = {}
all_vehicles_kill_engine = false; vehicles_kill_engine = {}
all_vehicles_lock_doors = false; vehicles_lock_doors = {}
all_vehicles_catapult = false
all_vehicles_flee = false; vehicles_flee = {}
all_vehicles_include_players = false

menu.toggle(world_all_vehicles_root, "Make Fast", {"ryanallvehiclesfast"}, "Makes all nearby vehicles fast.", function(value)
    all_vehicles_make_fast = value
end, false)
menu.toggle(world_all_vehicles_root, "Make Slow", {"ryanallvehiclesslow"}, "Makes all nearby vehicles slow.", function(value)
    all_vehicles_make_slow = value
end, false)
menu.toggle(world_all_vehicles_root, "No Grip", {"ryanallvehiclesnogrip"}, "Makes all nearby vehicles drift.", function(value)
    all_vehicles_no_grip = value
end, false)
menu.toggle(world_all_vehicles_root, "Burst Tires", {"ryanallvehiclesburst"}, "Makes all nearby vehicles have sudden tire loss.", function(value)
    all_vehicles_burst_tires = value
end, false)
menu.toggle(world_all_vehicles_root, "Kill Engine", {"ryanallvehiclesdead"}, "Makes all nearby vehicles dead.", function(value)
    all_vehicles_kill_engine = value
end, false)
menu.toggle(world_all_vehicles_root, "Lock Doors", {"ryanallvehicleslocked"}, "Locks all nearby vehicles.", function(value)
    all_vehicles_lock_doors = value
end, false)
menu.toggle(world_all_vehicles_root, "Catapult", {"ryanallvehiclescatapult"}, "Makes all nearby vehicles catapult in the air.", function(value)
    all_vehicles_catapult = value
end, false)
menu.toggle(world_all_vehicles_root, "Flee", {"ryanallvehiclesflee"}, "Makes all nearby vehicles flee.", function(value)
    all_vehicles_flee = value
end, false)
menu.divider(world_all_vehicles_root, "Options")
menu.toggle(world_all_vehicles_root, "Include Players", {"ryanallvehiclesplayers"}, "If enabled, player-driven vehicles are affected too.", function(value)
    all_vehicles_include_players = value
end)

util.create_tick_handler(function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 250, NearbyEntities.Vehicles)
    for _, vehicle in pairs(vehicles) do
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        if all_vehicles_include_players or not PED.IS_PED_A_PLAYER(driver) then
            local make_fast = nil
            for i = 1, #vehicles_make_fast do
                if vehicles_make_fast[i] == vehicle then make_fast = i end
            end
            if all_vehicles_make_fast and not make_fast then
                vehicle_set_speed(vehicle, VehicleSpeed.Fast)
                table.insert(vehicles_make_fast, vehicle)
            elseif not all_vehicles_make_fast and make_fast then
                vehicle_set_speed(vehicle, VehicleSpeed.Normal)
                table.remove(vehicles_make_fast, make_fast)
            end

            local make_slow = nil
            for i = 1, #vehicles_make_slow do
                if vehicles_make_slow[i] == vehicle then make_slow = i end
            end
            if all_vehicles_make_slow and not make_slow then
                vehicle_set_speed(vehicle, VehicleSpeed.Slow)
                table.insert(vehicles_make_slow, vehicle)
            elseif not all_vehicles_make_slow and make_slow then
                vehicle_set_speed(vehicle, VehicleSpeed.Normal)
                table.remove(vehicles_make_slow, make_slow)
            end

            local no_grip = nil
            for i = 1, #vehicles_no_grip do
                if vehicles_no_grip[i] == vehicle then no_grip = i end
            end
            if all_vehicles_no_grip and not no_grip then
                vehicle_set_no_grip(vehicle, true)
                table.insert(vehicles_no_grip, vehicle)
            elseif not all_vehicles_no_grip and no_grip then
                vehicle_set_no_grip(vehicle, false)
                table.remove(vehicles_no_grip, no_grip)
            end

            local burst_tires = nil
            for i = 1, #vehicles_burst_tires do
                if vehicles_burst_tires[i] == vehicle then burst_tires = i end
            end
            if all_vehicles_burst_tires and not burst_tires then
                vehicle_set_tires_bursted(vehicle, true)
                table.insert(vehicles_burst_tires, vehicle)
            elseif not all_vehicles_burst_tires and burst_tires then
                vehicle_set_tires_bursted(vehicle, false)
                table.remove(vehicles_burst_tires, burst_tires)
            end

            local kill_engine = nil
            for i = 1, #vehicles_kill_engine do
                if vehicles_kill_engine[i] == vehicle then kill_engine = i end
            end
            if all_vehicles_kill_engine and not kill_engine then
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                table.insert(vehicles_kill_engine, vehicle)
            elseif not all_vehicles_kill_engine and kill_engine then
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                table.remove(vehicles_kill_engine, kill_engine)
            end

            local lock_doors = nil
            for i = 1, #vehicles_lock_doors do
                if vehicles_lock_doors[i] == vehicle then lock_doors = i end
            end
            if all_vehicles_lock_doors and not lock_doors then
                vehicle_set_doors_locked(vehicle, true)
                table.insert(vehicles_lock_doors, vehicle)
            elseif not all_vehicles_lock_doors and lock_doors then
                vehicle_set_doors_locked(vehicle, false)
                table.remove(vehicles_lock_doors, lock_doors)
            end

            if all_vehicles_catapult then
                vehicle_catapult(vehicle)
            end

            if not PED.IS_PED_A_PLAYER(driver) then
                local flee = nil
                for i = 1, #vehicles_flee do
                    if vehicles_flee[i] == vehicle then flee = i end
                end
                if all_vehicles_flee and not flee then
                    TASK.TASK_SMART_FLEE_PED(driver, player_get_ped(), 250.0, -1, false, false)
                    table.insert(vehicles_flee, vehicle)
                elseif not all_vehicles_flee and flee then
                    TASK.CLEAR_PED_TASKS(driver)
                    table.remove(vehicles_flee, flee)
                end
            end
        end
    end

    util.yield(500)
end)

-- -- All NPCs
all_npcs_mode = "Off"

for _, mode in pairs(NPCScenarios) do
    menu.toggle(world_all_npcs_root, mode, {"ryanallnpcs" .. mode:lower()}, "", function(value)
        if value then
            menu.trigger_commands("ryanallnpcs" .. all_npcs_mode:lower() .. " off")
            all_npcs_mode = mode
        end
    end, mode == "Off")
end

npcs_affected = {}
util.create_tick_handler(function()
    if all_npcs_mode ~= "Off" then
        local scenario = ""
        if all_npcs_mode == "Musician" then scenario = "WORLD_HUMAN_MUSICIAN"
        elseif all_npcs_mode == "Human Statue" then scenario = "WORLD_HUMAN_HUMAN_STATUE"
        elseif all_npcs_mode == "Paparazzi" then scenario = "WORLD_HUMAN_PAPARAZZI"
        elseif all_npcs_mode == "Janitor" then scenario = "WORLD_HUMAN_JANITOR" end

        local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped())
        for _, ped in pairs(entity_get_all_nearby(coords, 200, NearbyEntities.Peds)) do
            if not PED.IS_PED_A_PLAYER(ped) and not PED.IS_PED_IN_ANY_VEHICLE(ped) then
                local was_affected = false
                for _, npc in pairs(npcs_affected) do
                    if npc == ped then was_affected = true end
                end
                if not was_affected then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(ped, all_npcs_mode, 0, true)
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
        player_teleport_to({x = ActionFigures[i][1], y = ActionFigures[i][2], z = ActionFigures[i][3]})
    end)
end

-- -- Signal Jammers
for i = 1, #SignalJammers do
    menu.action(world_signal_jammers_root, "Signal Jammer " .. i, {"ryansignaljammer" .. i}, "Teleports to signal jammer #" .. i, function()
        player_teleport_with_vehicle_to({x = SignalJammers[i][1], y = SignalJammers[i][2], z = SignalJammers[i][3]})
    end)
end

-- -- Playing Cards
for i = 1, #PlayingCards do
    menu.action(world_playing_cards_root, "Playing Card " .. i, {"ryanplayingcard" .. i}, "Teleports to playing card #" .. i, function()
        player_teleport_with_vehicle_to({x = PlayingCards[i][1], y = PlayingCards[i][2], z = PlayingCards[i][3]})
    end)
end

-- -- No Cops
menu.toggle_loop(world_root, "No Cops", {"ryannocops"}, "Clears the area of cops while enabled.", function()
    local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, 500, 0) -- might as well
    for _, entity in pairs(entity_get_all_nearby(coords, 500, NearbyEntities.All)) do
        if ENTITY.IS_ENTITY_A_PED(entity) then
            for _, ped_type in pairs(PolicePeds) do
                if PED.GET_PED_TYPE(entity) == ped_type then
                    entity_request_control(entity)
                    entities.delete_by_handle(entity)
                end
            end
        elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            for _, vehicle_model in pairs(PoliceVehicles) do
                if VEHICLE.IS_VEHICLE_MODEL(entity, vehicle_model) then
                    entity_request_control(entity)
                    entities.delete_by_handle(entity)
                end
            end
        end
    end
    util.yield(250)
    -- SEARCHLIGHT
end, false)

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

-- -- Fireworks
function do_fireworks(burst_type, coords, color)
    coords = vector_add(firework_coords, coords)
    local ptfx = nil
    for _, ptfx_data in pairs(PTFX) do
        if ptfx_data[1] == burst_type then ptfx = ptfx_data end
    end
    ptfx_play_at_coords(coords, ptfx[2], ptfx[3], color)
    audio_play_at_coords(coords, "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 100)
    audio_play_at_coords(vector_add(coords, {x = 50, y = 50, z = 0}), "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 500)
    audio_play_at_coords(vector_add(coords, {x = -50, y = -50, z = 0}), "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 500)
    audio_play_at_coords(vector_add(coords, {x = 75, y = 75, z = 0}), "PLAYER_SWITCH_CUSTOM_SOUNDSET", "Hit_Out", 100)
end

firework_coords = nil -- {x = -1800, y = -1000, z = 85}
menu.toggle(world_root, "Fireworks Show", {"ryanfireworkshow"}, "A nice display of liberty on the second worst beach in America.", function(value)
    firework_coords = value and ENTITY.GET_ENTITY_COORDS(player_get_ped()) or nil
end)
util.create_tick_handler(function()
    if firework_coords ~= nil then
        local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
        do_fireworks("Firework Burst", {x = math.random(-150, 150), y = math.random(-200, 50), z = math.random(-25, 25)}, color)

        if math.random(1, 10) == 2 then
            local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
            local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
            do_fireworks("Firework Burst", vector_add(offset, {x = 8, y = 8, z = 0}), color)
            do_fireworks("Firework Burst", vector_add(offset, {x = -8, y = 8, z = 0}), color)
            do_fireworks("Firework Burst", vector_add(offset, {x = 8, y = -8, z = 0}), color)
            do_fireworks("Firework Burst", vector_add(offset, {x = -8, y = -8, z = 0}), color)
        end
        if math.random(1, 10) == 8 then
            local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
            local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
            for i = 1, math.random(3, 6) do
                util.yield(math.random(75, 500))
                do_fireworks("Firework Burst", vector_add(offset, {x = 8, y = i + 8, z = 0}), color)
                do_fireworks("Firework Burst", vector_add(offset, {x = 8, y = -i - 8, z = 0}), color)
            end
        end

        util.yield(math.random(150, 650))
    end
end)


-- Session Menu --
session_trolling_root = menu.list(session_root, "Trolling...", {"ryantrolling"}, "Trolling options on all players.")
session_nuke_root = menu.list(session_root, "Nuke...", {"ryannuke"}, "Plays a siren, timer, and bomb with additional earrape.")
session_dox_root = menu.list(session_root, "Dox...", {"ryandox"}, "Shares information players probably want private.")

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
    session_watch_and_do_command_all({"enemyclone{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Chop", {"ryanattackallchop"}, "Sends Chop to attack all players.", function()
    util.toast("Sending Chop after all players...")
    session_watch_and_do_command_all({"sendchop{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Police", {"ryanattackallpolice"}, "Sends the law to attack all players.", function()
    util.toast("Sending a police car after all players...")
    session_watch_and_do_command_all({"sendpolicecar{name}"}, trolling_include_modders, trolling_watch_time)
end)

menu.divider(session_trolling_root, "Vehicle")
menu.action(session_trolling_root, "Tow", {"ryantowall"}, "Sends a tow truck to all players.", function()
    util.toast("Towing all players...")
    session_watch_and_do_command_all({"towtruck{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Make Fast", {"ryanmakefastall"}, "Makes everyone's vehicles fast.", function()
    util.toast("Making all players' cars fast...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_set_speed(vehicle, VehicleSpeed.Fast)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Make Slow", {"ryanmakeslowall"}, "Makes everyone's vehicles slow.", function()
    util.toast("Making all players' cars slow...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_set_speed(vehicle, VehicleSpeed.Slow)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "No Grip", {"ryanmakenogripall"}, "Makes everyone's vehicles drift.", function()
    util.toast("Making all players' cars drift...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_set_no_grip(vehicle, true)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Lock Doors", {"ryanlockall"}, "Makes everyone's vehicle's doors locked.", function()
    util.toast("Making all players' cars locked...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_set_doors_locked(vehicle, true)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Burst Tires", {"ryanbursttiresall"}, "Bursts everyone's tires.", function()
    util.toast("Bursting all tires...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_set_tires_bursted(vehicle, true)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Kill Engine", {"ryankillengineall"}, "Kills everyone's engine.", function()
    util.toast("Killing all engines...")
    session_watch_and_takeover_all(function(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Catapult", {"ryancatapultall"}, "Catapults everyone's vehicles.", function()
    util.toast("Catapulting all players...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_catapult(vehicle)
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
    session_explode_all(true)
    if nuke_spam_enabled then
        session_spam_chat(nuke_spam_message, true, 100, 0)
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

-- -- Crash All
session_crash_all_root = menu.list(session_root, "Crash All...", {"ryancrashall"}, "The ultimate session crash.")
crash_all_friends = false
crash_all_modders = false

menu.action(session_crash_all_root, "Crash To Singleplayer", {"ryancrashallsingleplayer"}, "Attempts to crash using all to singleplayer.", function()
    for _, player_id in pairs(players.list(false, crash_all_friends)) do
        if crash_all_modders or not players.is_marked_as_modder(player_id) then
            util.create_thread(function()
                player_crash_to_singleplayer(player_id)
            end)
        end
    end
end)
menu.action(session_crash_all_root, "Crash To Desktop", {"ryancrashallmultiplayer"}, "Attempts to crash using all known entities.", function()
    local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped())
    local in_danger_zone = false
    for _, player_id in pairs(players.list(false, crash_all_friends)) do
        if vector_distance(ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id)), starting_coords) < SafeCrashDistance then
            in_danger_zone = true
        end
    end

    if in_danger_zone then
        player_teleport_to(SafeCrashCoords)
        util.yield(1000)
    end
    for _, player_id in pairs(players.list(false, crash_all_friends)) do
        if crash_all_modders or not players.is_marked_as_modder(player_id) then
            player_crash_to_desktop(player_id, "Vegetation")
            player_crash_to_desktop(player_id, "Invalid Peds")
        end
    end
    if in_danger_zone then
        util.yield(SafeCrashDuration)
        player_teleport_to(starting_coords)
    end
end)

menu.divider(session_crash_all_root, "Options")
menu.toggle(session_crash_all_root, "Include Friends", {"ryanomnicrashfriends"}, "If enabled, friends are included in the Omnicrash.", function(value)
    crash_all_friends = value
end)
menu.toggle(session_crash_all_root, "Include Modders", {"ryanomnicrashmodders"}, "If enabled, modders are included in the Omnicrash.", function(value)
    crash_all_modders = value
end)

-- -- Anti-Hermit
session_antihermit_root = menu.list(session_root, "Anti-Hermit...", {"ryanantihermit"}, "Kicks or trolls any player who stays inside for more than 5 minutes.")
antihermit_mode = "Off"

for _, mode in pairs(AntihermitMode) do
    menu.toggle(session_antihermit_root, mode, {"ryanantihermit" .. mode:lower()}, "", function(value)
        if value then
            menu.trigger_commands("ryanantihermit" .. antihermit_mode:lower() .. " off")
            antihermit_mode = mode
        end
    end, mode == "Off")
end

hermits = {}
util.create_tick_handler(function()
    if antihermit_mode ~= "Off" then
        for _, player_id in pairs(players.list(false)) do
            if not players.is_marked_as_modder(player_id) then
                local tracked = false
                local player_name = players.get_name(player_id)
                if players.is_in_interior(player_id) then
                    if hermits[player_id] == nil then
                        hermits[player_id] = util.current_time_millis()
                        util.toast(player_name .. " is now inside a building.")
                    elseif util.current_time_millis() - hermits[player_id] >= 300000 then
                        hermits[player_id] = util.current_time_millis() - 210000
                        basics_show_text_message(Color.Purple, "Anti-Hermit", player_name .. " has been inside for 5 minutes. Now doing: " .. antihermit_mode .. "!")
                        player_do_sms_spam(player_id, "You've been inside too long. Stop being weird and play the game!", 3000)
                        if antihermit_mode == "Teleport Outside" then
                            menu.trigger_commands("apt1" .. player_name)
                        elseif antihermit_mode == "Kick" then
                            menu.trigger_commands("kick" .. player_name)
                        elseif antihermit_mode == "Crash" then
                            menu.trigger_commands("footlettuce" .. player_name)
                        end
                    end
                else
                    if hermits[player_id] ~= nil then 
                        util.toast(player_name .. " is no longer inside a building after " .. basics_format_time(util.current_time_millis() - hermits[player_id]) .. ".")
                        hermits[player_id] = nil
                    end
                end
            end
        end
    end
    util.yield(500)
end)

-- -- Fake Money Drop
menu.toggle_loop(session_root, "Fake Money Drop", {"ryanfakemoneyall"}, "Drops fake money bags on all players.", function()
    for _, player_id in pairs(players.list()) do
        util.create_thread(function()
            player_fake_money_drop(player_id)
        end)
    end
    util.yield(125)
end, false)

-- -- Mk II Chaos
menu.toggle_loop(session_root, "Mk II Chaos", {"ryanmk2chaos"}, "Gives everyone a Mk 2 and tells them to duel.", function()
    chat.send_message("This session is in Mk II Chaos mode! Every 3 minutes, everyone receives an Oppressor. Good luck.", false, true, true)
    local oppressor2 = util.joaat("oppressor2")
    basics_request_model(oppressor2)
    for _, player_id in pairs(players.list()) do
        local player_ped = player_get_ped(player_id)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 5.0, 0.0)
        local vehicle = entities.create_vehicle(oppressor2, coords, ENTITY.GET_ENTITY_HEADING(player_ped))
        vehicle_set_upgraded(vehicle, true)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, true)
        VEHICLE.SET_VEHICLE_DOOR_LATCHED(vehicle, 0, false, false, true)
    end
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(oppressor2)
    util.yield(180000)
end, false)


-- Stats Menu --
menu.divider(stats_root, "Player")
stats_kd_root = menu.list(stats_root, "Kills/Deaths...", {"ryankd"}, "Controls your kills and deaths.")
menu.action(stats_root, "Favorite Radio Station", {"ryanradio"}, "Sets your favorite station to the one currently playing.", function()
    local station_name = AUDIO.GET_PLAYER_RADIO_STATION_NAME()
    
    if station_name ~= nil then
        STATS.STAT_SET_INT(stats_get_hash("MPPLY_MOST_FAVORITE_STATION"), util.joaat(station_name), true)
        basics_show_text_message(Color.Purple, "Favorite Radio Station", "Your favorite radio station has been updated!")
    else
        basics_show_text_message(Color.Red, "Favorite Radio Station", "You're not currently listening to the radio.")
    end
end)

menu.divider(stats_root, "World")
stats_office_money_root = menu.list(stats_root, "CEO Office Money...", {"ryanofficemoney"}, "Controls the amount of money in your CEO office.")
stats_mc_clutter_root = menu.list(stats_root, "MC Clubhouse Clutter...", {"ryanmcclutter"}, "Controls the amount of clutter in your clubhouse.")

-- -- Kills/Deaths
stats_kills, stats_deaths = nil, nil

function create_kd_inputs()
    if stats_kills ~= nil then menu.delete(stats_kills); stats_kills = nil end
    if stats_deaths ~= nil then menu.delete(stats_deaths); stats_deaths = nil end
    if stats_kd ~= nil then menu.delete(stats_kd); stats_kd = nil end

    stats_kills = menu.text_input(stats_kd_root, "Kills: -", {"ryankills"}, "The amount of kills you have given.", function(value)
        value = tonumber(value)
        if value ~= nil then
            stats_set_deaths(math.floor(value))
            basics_show_text_message(Color.Purple, "Stats", "Your kill count has been changed to " .. value .. "!")
        else
            basics_show_text_message(Color.Red, "Stats", "The kill count you provided was not a valid number.")
        end
        create_kd_inputs()
    end)

    stats_deaths = menu.text_input(stats_kd_root, "Deaths: -", {"ryandeaths"}, "The amount of deaths you have received.", function(value)
        value = tonumber(value)
        if value ~= nil then
            stats_set_deaths(math.floor(value))
            basics_show_text_message(Color.Purple, "Stats", "Your death count has been changed to " .. value .. "!")
        else
            basics_show_text_message(Color.Red, "Stats", "The death count you provided was not a valid number.")
        end
        create_kd_inputs()
    end)

    stats_kd = menu.divider(stats_kd_root, "K/D: -")
end

create_kd_inputs()

-- -- CEO Office Money
office_money_0 = menu.action(stats_office_money_root, "0% Full", {"ryanofficemoney0"}, "Makes the office 0% full with money.", function(click_type)
    stats_set_office_money(office_money_0, click_type, 0)
end)
office_money_25 = menu.action(stats_office_money_root, "25% Full", {"ryanofficemoney25"}, "Makes the office 25% full with money.", function(click_type)
    stats_set_office_money(office_money_25, click_type, 5000000)
end)
office_money_50 = menu.action(stats_office_money_root, "50% Full", {"ryanofficemoney50"}, "Makes the office 50% full with money.", function(click_type)
    stats_set_office_money(office_money_50, click_type, 10000000)
end)
office_money_75 = menu.action(stats_office_money_root, "75% Full", {"ryanofficemoney75"}, "Makes the office 75% full with money.", function(click_type)
    stats_set_office_money(office_money_75, click_type, 15000000)
end)
office_money_100 = menu.action(stats_office_money_root, "100% Full", {"ryanofficemoney100"}, "Makes the office 100% full with money.", function(click_type)
    stats_set_office_money(office_money_100, click_type, 20000000)
end)

-- -- MC Clubhouse Clutter
mc_clutter_0 = menu.action(stats_mc_clutter_root, "0% Full", {"ryanmcclutter0"}, "Removes drugs, money, and other clutter to your M.C. clubhouse.", function(click_type)
    stats_set_mc_clutter(mc_clutter_0, click_type, 0)
end)
mc_clutter_100 = menu.action(stats_mc_clutter_root, "100% Full", {"ryanmcclutter100"}, "Adds drugs, money, and other clutter to your M.C. clubhouse.", function(click_type)
    stats_set_mc_clutter(mc_clutter_100, click_type, 20000000)
end)

util.create_tick_handler(function()
    if stats_kills ~= nil and stats_deaths ~= nil then
        local kills, deaths = stats_get_kills(), stats_get_deaths()
        menu.set_menu_name(stats_kills, "Kills: " .. kills)
        menu.set_menu_name(stats_deaths, "Deaths: " .. deaths)
        menu.set_menu_name(stats_kd, "K/D: " .. string.format("%.2f", kills / deaths))
        util.yield(10000)
    end
end)


-- Player Options --
money_drop = {}
vehicle_speed = {}
vehicle_grip = {}
vehicle_doors = {}
vehicle_tires = {}
vehicle_engine = {}
vehicle_upgrades = {}

function setup_player(player_id)
    local player_root = menu.player_root(player_id)
    menu.divider(player_root, "Ryan's Menu")

    local player_name = players.get_name(player_id)
    local player_trolling_root = menu.list(player_root, "Trolling...", {"ryantrolling"}, "Options that players may not like.")
    local player_removal_root = menu.list(player_root, "Removal...", {"ryanremoval"}, "Options to remove the player forcibly.")


    -- Trolling --
    local player_vehicle_root = menu.list(player_trolling_root, "Vehicle...", {"ryanvehicle"}, "Vehicle trolling options.")


    -- Vehicle --
    -- -- Speed
    local player_vehicle_speed_root = menu.list(player_vehicle_root, "Speed: -", {"ryanspeed"}, "Changes the speed of their vehicle.")
    menu.toggle(player_vehicle_speed_root, "Fast", {"ryanspeedfast"}, "Makes the speed extremely fast.", function(value)
        if value then
            basics_run({
                "ryanspeednormal" .. player_name .. " off",
                "ryanspeedslow" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_speed[player_id] = "fast"
            menu.set_menu_name(player_vehicle_speed_root, "Speed: Fast")
        else
            vehicle_speed[player_id] = nil
            menu.set_menu_name(player_vehicle_speed_root, "Speed: -")
        end
    end)
    menu.toggle(player_vehicle_speed_root, "Slow", {"ryanspeedslow"}, "Makes the speed extremely slow.", function(value)
        if value then
            basics_run({
                "ryanspeedfast" .. player_name .. " off",
                "ryanspeednormal" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_speed[player_id] = "slow"
            menu.set_menu_name(player_vehicle_speed_root, "Speed: Slow")
        else
            vehicle_speed[player_id] = nil
            menu.set_menu_name(player_vehicle_speed_root, "Speed: -")
        end
    end)
    menu.toggle(player_vehicle_speed_root, "Normal", {"ryanspeednormal"}, "Makes the speed normal again.", function(value)
        if value then
            basics_run({
                "ryanspeedfast" .. player_name .. " off",
                "ryanspeedslow" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_speed[player_id] = "normal"
            menu.set_menu_name(player_vehicle_speed_root, "Speed: Normal")
        else
            vehicle_speed[player_id] = nil
            menu.set_menu_name(player_vehicle_speed_root, "Speed: -")
        end
    end)
    
    -- -- Grip
    local player_vehicle_grip_root = menu.list(player_vehicle_root, "Grip: -", {"ryangrip"}, "Changes the grip of their vehicle's wheels.")
    menu.toggle(player_vehicle_grip_root, "None", {"ryangripnone"}, "Makes the tires have no grip.", function(value)
        if value then
            basics_run({
                "ryangripfull" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_grip[player_id] = "none"
            menu.set_menu_name(player_vehicle_grip_root, "Grip: None")
        else
            vehicle_grip[player_id] = nil
            menu.set_menu_name(player_vehicle_grip_root, "Grip: -")
        end
    end)
    menu.toggle(player_vehicle_grip_root, "Full", {"ryangripfull"}, "Makes the grip normal again.", function(value)
        if value then
            basics_run({
                "ryangripnone" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_grip[player_id] = "full"
            menu.set_menu_name(player_vehicle_grip_root, "Grip: Full")
        else
            vehicle_grip[player_id] = nil
            menu.set_menu_name(player_vehicle_grip_root, "Grip: -")
        end
    end)

    -- -- Doors
    local player_vehicle_doors_root = menu.list(player_vehicle_root, "Doors: -", {"ryandoors"}, "Changes their vehicle's door lock state.")
    menu.toggle(player_vehicle_doors_root, "Lock", {"ryandoorslock"}, "Locks the vehicle's doors.", function(value)
        if value then
            basics_run({
                "ryandoorsunlock" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_doors[player_id] = "lock"
            menu.set_menu_name(player_vehicle_doors_root, "Doors: Lock")
        else
            vehicle_doors[player_id] = nil
            menu.set_menu_name(player_vehicle_doors_root, "Doors: -")
        end
    end)
    menu.toggle(player_vehicle_doors_root, "Unlock", {"ryandoorsunlock"}, "Unlocks the vehicle's doors.", function(value)
        if value then
            basics_run({
                "ryandoorslock" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_doors[player_id] = "unlock"
            menu.set_menu_name(player_vehicle_doors_root, "Doors: Unlock")
        else
            vehicle_doors[player_id] = nil
            menu.set_menu_name(player_vehicle_doors_root, "Doors: -")
        end
    end)

    -- -- Tires
    local player_vehicle_tires_root = menu.list(player_vehicle_root, "Tires: -", {"ryantires"}, "Changes their vehicle's tire health.")
    menu.toggle(player_vehicle_tires_root, "Burst", {"ryantiresburst"}, "Makes the vehicle's tires burst.", function(value)
        if value then
            basics_run({
                "ryantiresfix" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_tires[player_id] = "burst"
            menu.set_menu_name(player_vehicle_tires_root, "Tires: Burst")
        else
            vehicle_tires[player_id] = nil
            menu.set_menu_name(player_vehicle_tires_root, "Tires: -")
        end
    end)
    menu.toggle(player_vehicle_tires_root, "Fix", {"ryantiresfix"}, "Fixes the vehicle's tires.", function(value)
        if value then
            basics_run({
                "ryantiresburst" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_tires[player_id] = "fix"
            menu.set_menu_name(player_vehicle_tires_root, "Tires: Fix")
        else
            vehicle_tires[player_id] = nil
            menu.set_menu_name(player_vehicle_tires_root, "Tires: -")
        end
    end)

    -- -- Engine
    local player_vehicle_engine_root = menu.list(player_vehicle_root, "Engine: -", {"ryanengine"}, "Changes their vehicle's engine health.")
    menu.toggle(player_vehicle_engine_root, "Kill", {"ryanenginekill"}, "Makes the vehicle's engine die.", function(value)
        if value then
            basics_run({
                "ryanenginefix" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_engine[player_id] = "kill"
            menu.set_menu_name(player_vehicle_engine_root, "Engine: Kill")
        else
            vehicle_engine[player_id] = nil
            menu.set_menu_name(player_vehicle_engine_root, "Engine: -")
        end
    end)
    menu.toggle(player_vehicle_engine_root, "Fix", {"ryanenginefix"}, "Fixes the vehicle's engine.", function(value)
        if value then
            basics_run({
                "ryanenginekill" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_engine[player_id] = "fix"
            menu.set_menu_name(player_vehicle_engine_root, "Engine: Fix")
        else
            vehicle_engine[player_id] = nil
            menu.set_menu_name(player_vehicle_engine_root, "Engine: -")
        end
    end)

    -- -- Upgrades
    local player_vehicle_upgrades_root = menu.list(player_vehicle_root, "Upgrades: -", {"ryanengine"}, "Changes their vehicle's upgrades.")
    menu.toggle(player_vehicle_upgrades_root, "All", {"ryanupgradesall"}, "Fully upgrades the vehicle.", function(value)
        if value then
            basics_run({
                "ryanupgradesnone" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_upgrades[player_id] = "all"
            menu.set_menu_name(player_vehicle_upgrades_root, "Upgrades: All")
        else
            vehicle_upgrades[player_id] = nil
            menu.set_menu_name(player_vehicle_upgrades_root, "Upgrades: -")
        end
    end)
    menu.toggle(player_vehicle_upgrades_root, "None", {"ryanupgradesnone"}, "Fully downgrades the vehicle.", function(value)
        if value then
            basics_run({
                "ryanupgradesall" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_upgrades[player_id] = "none"
            menu.set_menu_name(player_vehicle_upgrades_root, "Upgrades: None")
        else
            vehicle_upgrades[player_id] = nil
            menu.set_menu_name(player_vehicle_upgrades_root, "Upgrades: -")
        end
    end)

    -- -- Catapult
    menu.toggle_loop(player_vehicle_root, "Catapult", {"ryancatapult"}, "Catapults their car non-stop.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_catapult(vehicle)
            end
        end
        util.yield(500)
    end)


    -- Entities --
    local player_trolling_entities_root = menu.list(player_trolling_root, "Entities...", {"ryanentities"}, "Entity trolling options.")
    
    -- -- Stripper El Rubio
    menu.action(player_trolling_entities_root, "Pole-Dancing El Rubio", {"ryanelrubio"}, "Spawns an El Rubio whose fortune has been stolen, leading him to the pole.", function()
        local ped_coords = vector_add(
            ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id)),
            {x = math.random(-5, 5), y = math.random(-5, 5), z = 0}
        )

        local el_rubio = util.joaat("csb_juanstrickler"); basics_request_model(el_rubio)
        basics_request_animations("mini@strip_club@pole_dance@pole_dance1")

        local ped = entities.create_ped(1, el_rubio, ped_coords, ENTITY.GET_ENTITY_HEADING(player_get_ped(player_id)))
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(el_rubio)
        HUD.ADD_BLIP_FOR_ENTITY(ped)
        entity_request_control_loop(ped)
        TASK.TASK_PLAY_ANIM(ped, "mini@strip_club@pole_dance@pole_dance1", "pd_dance_01", 8.0, 0, -1, 9, 0, false, false, false)

        util.yield(300000)
        entities.delete_by_handle(ped)
    end)

    -- -- Transgender Go-Karts
    menu.action(player_trolling_entities_root, "Transgender Go-Karts", {"ryanmilitarykarts"}, "Spawns a military squad in go-karts.", function()
        player_go_karts(player_id, "a_m_m_tranvest_01")
    end)

    -- -- Trash Pickup
    menu.action(player_trolling_entities_root, "Trash Pickup", {"ryantrashpickup"}, "Send the trash man to 'clean up' the street. Yasha's idea.", function()
        player_trash_pickup(player_id)
    end)

    -- -- Flying Yacht
    menu.action(player_trolling_entities_root, "Flying Yacht", {"ryanflyingyacht"}, "Send the magic school yacht to fuck their shit up.", function()
        player_flying_yacht(player_id)
    end)
    
    -- -- Falling Tank
    menu.action(player_trolling_entities_root, "Falling Tank", {"ryantankkamikaze"}, "Send a tank straight from heaven.", function()
		local player_ped = player_get_ped(player_id)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        coords.z = coords.z + 10

        local tank = util.joaat("rhino"); basics_request_model(tank)
        local entity = entities.create_vehicle(tank, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(entity, true)
        ENTITY.SET_ENTITY_MAX_SPEED(entity, 64)
        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 3, 0.0, 0.0, -1000.00, 0.0, 0.0, 0.0, 0, true, true, false, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(tank)
    end)

    -- -- PTFX Attack
    menu.toggle_loop(player_trolling_root, "PTFX Attack", {"ryanptfxattack"}, "Tries to lag the player with PTFX.", function()
        ptfx_play_at_coords(ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id)), "core", "exp_grd_petrol_pump_post", {r = 0, g = 0, b = 0})
        ptfx_play_at_coords(ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id)), "core", "exp_grd_petrol_pump", {r = 0, g = 0, b = 0})
    end)

    -- -- Fake Money Drop
    menu.toggle(player_trolling_root, "Fake Money Drop", {"ryanfakemoney"}, "Drops fake money bags on the player.", function(value)
        money_drop[player_id] = value and true or nil
    end)
    

    -- -- No Godmode
    local remove_godmode_notice = 0
    menu.toggle_loop(player_trolling_root, "Remove Godmode", {"ryanremovegodmode"}, "Removes godmode from Kiddions users and their vehicles.", function()
        player_remove_godmode(player_id, true)
        if util.current_time_millis() - remove_godmode_notice >= 10000 then
            util.toast("Still removing godmode from " .. players.get_name(player_id) .. ".")
            remove_godmode_notice = util.current_time_millis()
        end
    end, false)


    -- Removal --
    -- -- Text & Kick
    local removal_block_joins = false
    local removal_message = ""
    
    menu.text_input(player_removal_root, "Spam Message", {"ryanremovalspam"}, "The message to spam before kicking.", function(value)
        removal_message = value
    end, removal_message)
    menu.toggle(player_removal_root, "Block Joins", {"ryanremovalblockjoins"}, "Block joins by this player.", function(value)
        removal_block_joins = value
    end)

    menu.divider(player_removal_root, "Go")
    -- -- Stand Kick
    menu.action(player_removal_root, "Stand Kick", {"ryankick"}, "Attempts to kick using Stand's Smart kick.", function()
        player_spam_and_block(player_id, removal_block_joins, removal_message, function()
            local player_name = players.get_name(player_id)
            menu.trigger_commands("kick" .. player_name)
        end)
    end)

    -- -- Crash To Singleplayer
    menu.action(player_removal_root, "Crash To Singleplayer", {"ryancrash"}, "Attempts to crash using all known script events.", function()
        player_spam_and_block(player_id, removal_block_joins, removal_message, function()
            player_crash_to_singleplayer(player_id)
        end)
    end)

    -- -- Crash To Desktop
    player_crash_to_desktop_root = menu.list(player_removal_root, "Crash To Desktop...", {"ryancrashes"}, "Various methods of crashing to desktop.")
    
    menu.action(player_crash_to_desktop_root, "Do All", {"ryandesktop"}, "Attempts to crash using all known entities.", function(click_type)
        player_spam_and_block(player_id, removal_block_joins, removal_message, function()
            local starting_coords = ENTITY.GET_ENTITY_COORDS(player_get_ped())
            local in_danger_zone = vector_distance(ENTITY.GET_ENTITY_COORDS(player_get_ped(player_id)), starting_coords) < SafeCrashDistance
            if in_danger_zone then
                player_teleport_to(SafeCrashCoords)
                util.yield(1000)
            end
            player_crash_to_desktop(player_id)
            if in_danger_zone then
                util.yield(SafeCrashDuration)
                player_teleport_to(starting_coords)
            end
        end)
    end)

    menu.divider(player_crash_to_desktop_root, "Methods")
    for _, mode in pairs(CrashToDesktopMethod) do
        menu.action(player_crash_to_desktop_root, mode, {"ryan" .. mode}, "Attempts to crash using the " .. mode .. " method.", function(click_type)
            player_spam_and_block(player_id, removal_block_joins, removal_message, function()
                player_crash_to_desktop(player_id, mode)
            end)
        end)
    end


    -- Divorce Kick --
    menu.action(player_root, "Divorce", {"ryandivorce"}, "Kicks the player, then blocks future joins by them.", function()
        local player_name = players.get_name(player_id)
        player_block_joins(player_name)
        menu.trigger_commands("kick" .. player_name)
        menu.trigger_commands("players")
    end)
end

util.create_thread(function()
    while true do
        for player_id, _ in pairs(money_drop) do
            player_fake_money_drop(player_id)
        end
        util.yield()
    end
end)

function get_control(player_id, action)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
    if vehicle ~= NULL then
        entity_request_control_loop(vehicle)
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
            action(vehicle)
        end
    end
end

util.create_tick_handler(function()
    for _, player_id in pairs(players.list()) do
        -- Speed
        if vehicle_speed[player_id] == "fast" then
            get_control(player_id, function(vehicle)
                vehicle_set_speed(vehicle, VehicleSpeed.Fast)
            end)
        elseif vehicle_speed[player_id] == "slow" then
            get_control(player_id, function(vehicle)
                vehicle_set_speed(vehicle, VehicleSpeed.Slow)
            end)
        elseif vehicle_speed[player_id] == "normal" then
            get_control(player_id, function(vehicle)
                vehicle_set_speed(vehicle, VehicleSpeed.Normal)
            end)
        end

        -- Grip
        if vehicle_grip[player_id] == "none" then
            get_control(player_id, function(vehicle)
                vehicle_set_no_grip(vehicle, true)
            end)
        elseif vehicle_grip[player_id] == "full" then
            get_control(player_id, function(vehicle)
                vehicle_set_no_grip(vehicle, false)
            end)
        end

        -- Doors
        if vehicle_doors[player_id] == "lock" then
            get_control(player_id, function(vehicle)
                vehicle_set_doors_locked(vehicle, true)
            end)
        elseif vehicle_doors[player_id] == "unlock" then
            get_control(player_id, function(vehicle)
                vehicle_set_doors_locked(vehicle, false)
            end)
        end

        -- Tires
        if vehicle_tires[player_id] == "burst" then
            get_control(player_id, function(vehicle)
                vehicle_set_tires_bursted(vehicle, true)
            end)
        elseif vehicle_tires[player_id] == "fix" then
            get_control(player_id, function(vehicle)
                vehicle_set_tires_bursted(vehicle, false)
            end)
        end

        -- Engine
        if vehicle_engine[player_id] == "kill" then
            get_control(player_id, function(vehicle)
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
            end)
        elseif vehicle_engine[player_id] == "fix" then
            get_control(player_id, function(vehicle)
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
            end)
        end

        -- Upgrades
        if vehicle_upgrades[player_id] == "all" then
            get_control(player_id, function(vehicle)
                vehicle_set_upgraded(vehicle, true)
            end)
        elseif vehicle_upgrades[player_id] == "none" then
            get_control(player_id, function(vehicle)
                vehicle_set_upgraded(vehicle, false)
            end)
        end
    end
    util.yield(250)
end)


-- Chat Menu --
menu.divider(chat_root, "Translate")
chat_new_message_root = menu.list(chat_root, "New Message...", {"ryanchatnew"})
chat_history_root = menu.list(chat_root, "Message History...", {"ryanchathistory"})

-- -- Send Message
chat_message = ""
chat_prefix = ""

-- -- Message
menu.text_input(chat_new_message_root, "Message", {"ryanchatmessage"}, "The message to send in chat.", function(value)
    chat_message = value
end, "")

-- -- Send Message
chat_send_root = menu.list(chat_new_message_root, "Send...", {"ryantranslatesend"}, "Translate and send the message.")
menu.action(chat_send_root, "Send", {"ryanchatsend"}, "Send without translating.", function()
    chat.send_message(chat_prefix .. chat_message, false, true, true)
    menu.focus(chat_send_root)
end)

menu.divider(chat_new_message_root, "Options")

-- -- Logo
chat_prefix_root = menu.list(chat_new_message_root, "Logo: None", {"ryanchatlogo"}, "Adds a special logo to the beginning of the message.")
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

menu.divider(chat_send_root, "Translate")
menu.action(chat_send_root, "Spanish", {"ryantranslatespanish"}, "Translate to Spanish.", function()
    util.toast("Translating message to Spanish...")
    session_translate_to(chat_prefix .. chat_message, "ES", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Russian", {"ryantranslaterussian"}, "Translate to Russian.", function()
    util.toast("Translating message to Russian...")
    session_translate_to(chat_prefix .. chat_message, "RU", true)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Russian (Cyrillic)", {"ryantranslatecyrillic"}, "Translate to Russian (Cyrillic).", function()
    util.toast("Translating message to Russian (Cyrillic)...")
    session_translate_to(chat_prefix .. chat_message, "RU", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "French", {"ryantranslatefrench"}, "Translate to French.", function()
    util.toast("Translating message to French...")
    session_translate_to(chat_prefix .. chat_message, "FR", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "German", {"ryantranslategerman"}, "Translate to German.", function()
    util.toast("Translating message to German...")
    session_translate_to(chat_prefix .. chat_message, "DE", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Italian", {"ryantranslateitalian"}, "Translate to Italian.", function()
    util.toast("Translating message to Italian...")
    session_translate_to(chat_prefix .. chat_message, "IT", false)
    menu.focus(chat_send_root)
end)

menu.divider(chat_root, "Chat Options")
-- -- Kick Money Beggars
kick_money_beggars = false
menu.toggle(chat_root, "Kick Money Beggars", {"ryankickbeggars"}, "Kicks anyone who begs for money.", function(value)
    kick_money_beggars = value
end)

-- -- Kick Car Meeters
kick_car_meeters = false
menu.toggle(chat_root, "Kick Car Meeters", {"ryankickcarmeets"}, "Kicks anyone who suggests a car meet.", function(value)
    kick_car_meeters = value
end)

chat_history = {}
chat_index = 1
chat.on_message(function(packet_sender, sender, message, is_team_chat)
    --if sender ~= players.user() then
    local message_lower = message:lower()
    if kick_money_beggars then
        if (message_lower:find("can") or message_lower:find("?") or message_lower:find("please") or message_lower:find("plz") or message_lower:find("pls") or message_lower:find("drop"))
            and message_lower:find("money") then
                basics_show_text_message(Color.Purple, "Kick Money Beggars", players.get_name(sender) .. " is being kicked for begging for money drops.")
                menu.trigger_commands("footlettuce" .. players.get_name(sender))
        end
    end
    if kick_car_meeters then
        if (message_lower:find("want to") or message_lower:find("wanna") or message_lower:find("at") or message_lower:find("is") or message_lower:find("?"))
            and message_lower:find("car") and message_lower:find("meet") then
                basics_show_text_message(Color.Purple, "Kick Car Meeters", players.get_name(sender) .. " is being kicked for suggesting a car meet.")
                menu.trigger_commands("footlettuce" .. players.get_name(sender))
        end
    end
    --end

    if #chat_history > 30 then
        menu.delete(chat_history[1])
        table.remove(chat_history, 1)
    end
    table.insert(
        chat_history,
        menu.action(chat_history_root, "\"" .. message .. "\"", {"ryanchathistory" .. chat_index}, "Translate this message into English.", function()
            session_translate_from(message)
        end)
    )
    chat_index = chat_index + 1
end)


-- Settings Menu --
esp_color = {r = 0.29, g = 0.69, b = 1.0}
menu.divider(settings_root, "Updates")
menu.action(settings_root, "Version: " .. VERSION, {}, "The currently installed version.", function() end)
menu.hyperlink(settings_root, "Website", "https://ryan.gq/menu/", "Opens the official website, for downloading the installer and viewing the changelog.")
menu.divider(settings_root, "Options")
menu.colour(settings_root, "ESP Color", {"ryanespcolor"}, "The color of on-screen ESP.", 0.29, 0.69, 1.0, 1.0, false, function(color)
    esp_color.r = color.r
    esp_color.g = color.g
    esp_color.b = color.b
end)
menu.action(settings_root, "Allow Fireworks", {"ryanallowfireworks"}, "Disable Crash Event - Timeout to allow for fireworks.", function()
    menu.focus(menu.ref_by_path("Online>Protections>Events>Crash Event>Timeout"))
end)


-- Initialize --
players.on_join(function(player_id) setup_player(player_id) end)
players.dispatch_on_join()

util.keep_running()


-- DirectX --
while true do
    player_is_pointing = memory.read_int(memory.script_global(4516656 + 930)) == 3
    if crosshair_mode == "Always" or (crosshair_mode == "When Pointing" and player_is_pointing) then
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