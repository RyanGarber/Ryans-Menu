VERSION = "0.6.7"
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
        basics_show_text_message(49, "v" .. VERSION, "You're up to date. Enjoy!")
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
self_ptfx_vehicle_wheels_root = menu.list(self_ptfx_vehicle_root, "Wheels...", {"ryanptfxwheels"}, "Special FX on the wheels of your vehicle.")
self_ptfx_vehicle_exhaust_root = menu.list(self_ptfx_vehicle_root, "Exhaust...", {"ryanptfxexhaust"}, "Speicla FX on the exhaust of your vehicle.")

ptfx_create_list(self_ptfx_vehicle_wheels_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(), true)
    if vehicle ~= NULL then
        ptfx_play_on_entity_bones(vehicle, VehicleBones.Wheels, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

ptfx_create_list(self_ptfx_vehicle_exhaust_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(), true)
    if vehicle ~= NULL then
        ptfx_play_on_entity_bones(vehicle, VehicleBones.Exhaust, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
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
            ptfx_play_at_coords(raycast.hit_coords, ptfx[1], ptfx[2], ptfx_color)
            util.yield(ptfx[3])
        end
    end
end)

ptfx_create_list(self_ptfx_weapon_muzzle_root, function(ptfx)
    if ptfx_disable then return end
    local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(player_get_ped())
    if weapon ~= NULL then
        ptfx_play_at_entity_bone_coords(weapon, WeaponBones.Muzzle, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

ptfx_create_list(self_ptfx_weapon_muzzle_flash_root, function(ptfx)
    if ptfx_disable then return end
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
    if ptfx_disable then return end
    local impact_ptr = memory.alloc()
    if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(player_get_ped(), impact_ptr) then
        ptfx_play_at_coords(memory.read_vector3(impact_ptr), ptfx[1], ptfx[2], ptfx_color)
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
        ptfx_play_on_entity_bones(player_get_ped(), PlayerBones.Pointer, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

ptfx_create_list(self_ptfx_pointing_crosshair_root, function(ptfx)
    if ptfx_disable then return end
    if player_is_pointing then
        local raycast = basics_do_raycast(1000.0)
        if raycast.did_hit then
            ptfx_play_at_coords(raycast.hit_coords, ptfx[1], ptfx[2], ptfx_color)
            util.yield(ptfx[3])
        end
    end
end)

ptfx_create_list(self_ptfx_pointing_god_finger_root, function(ptfx)
    if ptfx_disable then return end
    if god_finger_target ~= nil then
        ptfx_play_at_coords(god_finger_target, ptfx[1], ptfx[2], ptfx_color)
        util.yield(ptfx[3])
    end
end)

-- -- Forcefield
forcefield_mode = ForcefieldModes.Off
forcefield_size = 10
forcefield_force = 1

self_forcefield_mode_root = menu.list(self_forcefield_root, "Mode: None", {"ryanforcefieldmode"}, "Forcefield mode.")
for mode_name, mode_id in pairs(ForcefieldModes) do
    menu.action(self_forcefield_mode_root, mode_name, {"ryanforcefield" .. mode_name:lower()}, "", function()
        forcefield_mode = mode_id
        menu.set_menu_name(self_forcefield_mode_root, "Mode: " .. mode_name)
        menu.focus(self_forcefield_mode_root)
    end)
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
    if forcefield_mode == ForcefieldModes.Push then -- Push
        local player_ped = player_get_ped()
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
		local nearby = entity_get_all_nearby(player_coords, forcefield_size, NearbyEntitiesModes.All)
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
    elseif forcefield_mode == ForcefieldModes.Destroy then -- Destroy
        ENTITY.SET_ENTITY_PROOFS(player_get_ped(), false, false, true, false, false, false, 1, false)

        local player_ped = player_get_ped()
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        local player_vehicle = entities.get_user_vehicle_as_handle()

        local nearby = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.All)
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

-- -- Burning Man
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

fire_finger_mode = FireFingerModes.Off
self_fire_finger_root = menu.list(self_fire_root, "Finger: Off", {"ryanfirefinger"}, "Catches things on fire from a distance when pressing E.")
menu.action(self_fire_finger_root, "Off", {"ryanfirefingeroff"}, "No fire finger.", function(value)
    fire_finger_mode = FireFingerModes.Off
    menu.set_menu_name(self_fire_finger_root, "Finger: Off")
    menu.focus(self_fire_finger_root)
end)
menu.action(self_fire_finger_root, "When Pointing", {"ryanfirefingerpointing"}, "Fire finger when pointing.", function(value)
    fire_finger_mode = FireFingerModes.WhenPointing
    menu.set_menu_name(self_fire_finger_root, "Finger: When Pointing")
    menu.focus(self_fire_finger_root)
end)
menu.action(self_fire_finger_root, "Always", {"ryanfirefingeralways"}, "Fire finger at all times.", function(value)
    fire_finger_mode = FireFingerModes.Always
    menu.set_menu_name(self_fire_finger_root, "Finger: Always")
    menu.focus(self_fire_finger_root)
end)

util.create_tick_handler(function()
    if fire_finger_mode == FireFingerModes.Always or (fire_finger_mode == FireFingerModes.WhenPointing and player_is_pointing) then
        if PAD.IS_CONTROL_JUST_PRESSED(21, 86) then
            local raycast = basics_do_raycast(250.0)
            if raycast.did_hit then
                FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 3, 100.0, false, false, 0.0)
            end
        end
    end
end)

self_crosshair_root = menu.list(self_root, "Crosshair: Off", {"ryancrosshair"}, "Addn-screen crosshair.")
crosshair_mode = CrosshairModes.Never

-- -- When Pointing
menu.action(self_crosshair_root, "Never", {"ryancrosshairnever"}, "Doesn't add a crosshair.", function(value)
    crosshair_mode = CrosshairModes.Never
    menu.set_menu_name(self_crosshair_root, "Crosshair: Never")
    menu.focus(self_crosshair_root)
end)

-- -- When Pointing
menu.action(self_crosshair_root, "When Pointing", {"ryancrosshairpointing"}, "Adds a crosshair when pointing.", function(value)
    crosshair_mode = CrosshairModes.WhenPointing
    menu.set_menu_name(self_crosshair_root, "Crosshair: When Pointing")
    menu.focus(self_crosshair_root)
end)

-- -- Always
crosshair_when_pointing = false
menu.action(self_crosshair_root, "Always", {"ryancrosshairalways"}, "Adds a crosshair at all times.", function(value)
    crosshair_mode = CrosshairModes.Always
    menu.set_menu_name(self_crosshair_root, "Crosshair: Always")
    menu.focus(self_crosshair_root)
end)

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
world_vehicles_root = menu.list(world_root, "All Vehicles...", {"ryanallvehicles"}, "Control the vehicles around you.")
world_npc_action_root = menu.list(world_root, "All NPCs: None", {"ryanallnpcs"}, "Changes the action NPCs are currently performing.")


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
            vehicle_set_speed(vehicle, VehicleSpeedModes.Fast)
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
            vehicle_set_speed(vehicle, VehicleSpeedModes.Slow)
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
            vehicle_set_doors_locked(vehicle, true)
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
            vehicle_set_tires_bursted(vehicle, true)
            table.insert(vehicles_bursted, vehicle)
        end
    end
    util.yield(250)
end, false)

-- -- Kill Vehicles
menu.toggle_loop(world_vehicles_root, "Kill Engine", {"ryanmakealldead"}, "Makes all nearby vehicles dead.", function()
    local player_ped = player_get_ped()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = entity_get_all_nearby(player_coords, 200, NearbyEntitiesModes.Vehicles)
    for _, vehicle in pairs(vehicles) do
        if vehicle ~= player_vehicle then
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
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
menu.action(world_npc_action_root, "None", {"ryanallnpcsnone"}, "Makes NPCs normal.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: None")
    menu.focus(world_npc_action_root)
    npc_action = nil
end)
menu.action(world_npc_action_root, "Musician", {"ryanallnpcsmusician"}, "Makes NPCs into musicians.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: Musician")
    menu.focus(world_npc_action_root)
    npc_action = "WORLD_HUMAN_MUSICIAN"
end)
menu.action(world_npc_action_root, "Human Statue", {"ryanallnpcsstatue"}, "Makes NPCs into human statues.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: Human Statue")
    menu.focus(world_npc_action_root)
    npc_action = "WORLD_HUMAN_HUMAN_STATUE"
end)
menu.action(world_npc_action_root, "Paparazzi", {"ryanallnpcspaparazzi"}, "Makes NPCs into paparazzi.", function()
    menu.set_menu_name(world_npc_action_root, "All NPCs: Paparazzi")
    menu.focus(world_npc_action_root)
    npc_action = "WORLD_HUMAN_PAPARAZZI"
end)
menu.action(world_npc_action_root, "Janitor", {"ryanallnpcsjanitor"}, "Makes NPCs into janitors.", function()
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
        player_teleport_to(ActionFigures[i][1], ActionFigures[i][2], ActionFigures[i][3])
    end)
end

-- -- Signal Jammers
for i = 1, #SignalJammers do
    menu.action(world_signal_jammers_root, "Signal Jammer " .. i, {"ryansignaljammer" .. i}, "Teleports to signal jammer #" .. i, function()
        player_teleport_with_vehicle_to(SignalJammers[i][1], SignalJammers[i][2], SignalJammers[i][3])
    end)
end

-- -- Playing Cards
for i = 1, #PlayingCards do
    menu.action(world_playing_cards_root, "Playing Card " .. i, {"ryanplayingcard" .. i}, "Teleports to playing card #" .. i, function()
        player_teleport_with_vehicle_to(PlayingCards[i][1], PlayingCards[i][2], PlayingCards[i][3])
    end)
end

-- -- No Cops
menu.toggle_loop(world_root, "No Cops", {"ryannocops"}, "Clears the area of cops while enabled.", function()
    local coords = ENTITY.GET_ENTITY_COORDS(player_get_ped())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, 500, 0) -- might as well
    for _, entity in pairs(entity_get_all_nearby(coords, 500, NearbyEntitiesModes.All)) do
        if ENTITY.IS_ENTITY_A_PED(entity) then
            for _, ped_type in pairs(PolicePedTypes) do
                if PED.GET_PED_TYPE(entity) == ped_type then
                    entity_request_control(entity)
                    entities.delete_by_handle(entity)
                end
            end
        elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            for _, vehicle_model in pairs(PoliceVehicleModels) do
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
    ptfx_play_at_coords(coords, PTFX[burst_type][1], PTFX[burst_type][2], color)
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
        vehicle_set_speed(vehicle, VehicleSpeedModes.Fast)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Make Slow", {"ryanmakeslowall"}, "Makes everyone's vehicles slow.", function()
    util.toast("Making all players' cars slow...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_set_speed(vehicle, VehicleSpeedModes.Slow)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Make Drift", {"ryanmakedriftall"}, "Makes everyone's vehicles drift.", function()
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
menu.action(session_trolling_root, "Catapult", {"ryancatapultall"}, "Catapults everyone's vehicles.", function()
    util.toast("Catapulting all players...")
    session_watch_and_takeover_all(function(vehicle)
        vehicle_catapult(vehicle)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Kill Engine", {"ryankillengineall"}, "Kills everyone's engine.", function()
    util.toast("Killing all engines...")
    session_watch_and_takeover_all(function(vehicle)
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

-- -- Omnicrash
session_omnicrash_root = menu.list(session_root, "Omnicrash...", {"ryanomnicrashall"}, "The ultimate session crash.")
session_omnicrash_friends = false
session_omnicrash_modders = true

menu.action(session_omnicrash_root, "Go", {"ryanomnicrashallgo"}, "Attempts to crash using all known script events.", function()
    for _, player_id in pairs(players.list(false, session_omnicrash_friends)) do
        if session_omnicrash_modders or not players.is_marked_as_modder(player_id) then
            util.create_thread(function()
                player_omnicrash(player_id)
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

-- -- Kick Hermits
session_antihermit_root = menu.list(session_root, "Anti-Hermit: Disabled", {"ryanantihermit"}, "Kicks or trolls any player who stays inside for more than 5 minutes.")
antihermit_mode = "Disabled"

menu.action(session_antihermit_root, "Disabled", {"ryanantihermitdisabled"}, "Does nothing to hermits.", function()
    antihermit_mode = "Disabled"
    menu.set_menu_name(session_antihermit_root, "Anti-Hermit: Disabled")
    menu.focus(session_antihermit_root)
end)
menu.action(session_antihermit_root, "Teleport Outside", {"ryanantihermittpoutside"}, "Teleports hermits to an apartment, forcing them outside.", function()
    antihermit_mode = "Teleport Outside"
    menu.set_menu_name(session_antihermit_root, "Anti-Hermit: Teleport Outside")
    menu.focus(session_antihermit_root)
end)
menu.action(session_antihermit_root, "Stand Kick", {"ryanantihermitkick"}, "Kicks hermits from the session.", function()
    antihermit_mode = "Stand Kick"
    menu.set_menu_name(session_antihermit_root, "Anti-Hermit: Stand Kick")
    menu.focus(session_antihermit_root)
end)
menu.action(session_antihermit_root, "Omnicrash Mk II", {"ryanantihermitomnicrash"}, "Kicks hermits from the session.", function()
    antihermit_mode = "Omnicrash Mk II"
    menu.set_menu_name(session_antihermit_root, "Anti-Hermit: Omnicrash Mk II")
    menu.focus(session_antihermit_root)
end)
menu.action(session_antihermit_root, "Smelly Peepo Crash", {"ryanantihermitsmellypeepo"}, "Kicks hermits from the session.", function()
    antihermit_mode = "Smelly Peepo Crash"
    menu.set_menu_name(session_antihermit_root, "Anti-Hermit: Smelly Peepo Crash")
    menu.focus(session_antihermit_root)
end)

hermits = {}
util.create_tick_handler(function()
    if antihermit_mode ~= "Disabled" then
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
                        basics_show_text_message(Colors.Purple, "Anti-Hermit", player_name .. " has been inside for 5 minutes. Now doing: " .. antihermit_mode .. "!")
                        util.create_thread(function()
                            player_do_sms_spam(player_id, "You've been inside too long. Stop being weird and play the game!", 3000)
                        end)
                        if antihermit_mode == "Teleport Outside" then
                            menu.trigger_commands("apt1" .. player_name)
                        elseif antihermit_mode == "Stand Kick" then
                            menu.trigger_commands("kick" .. player_name)
                        elseif antihermit_mode == "Omnicrash Mk II" then
                            player_omnicrash(player_id)
                        elseif antihermit_mode == "Smelly Peepo Crash" then
                            player_smelly_peepo_crash(player_id)
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
stats_office_money_root = menu.list(stats_root, "CEO Office Money...", {"ryanofficemoney"}, "Controls the amount of money in your CEO office.")
stats_mc_clutter_root = menu.list(stats_root, "MC Clubhouse Clutter...", {"ryanmcclutter"}, "Controls the amount of clutter in your clubhouse.")

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


-- Player Options --
function setup_player(player_id)
    local player_root = menu.player_root(player_id)
    menu.divider(player_root, "Ryan's Menu")
    
    local player_trolling_root = menu.list(player_root, "Trolling...", {"ryantrolling"}, "Options that players may not like.")
    local player_removal_root = menu.list(player_root, "Removal...", {"ryanremoval"}, "Options to remove the player forcibly.")


    -- Trolling --
    local player_trolling_vehicle_root = menu.list(player_trolling_root, "Vehicle...", {"ryanvehicle"}, "Vehicle trolling options.")
    -- -- Make Fast
    menu.toggle(player_trolling_vehicle_root, "Make Fast", {"ryanfast"}, "Speeds up the car they are in.", function(value)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_speed(vehicle, value and VehicleSpeedModes.Fast or VehicleSpeedModes.Default)
            end
        end
        util.toast("Made " .. players.get_name(player_id) .. "'s car " .. (value and "fast" or "normal") .."!")
    end)

    -- -- Make Slow
    menu.toggle(player_trolling_vehicle_root, "Make Slow", {"ryanslow"}, "Slows the car they are in.", function(value)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_speed(vehicle, value and VehicleSpeedModes.Slow or VehicleSpeedModes.Default)
            end
        end
        util.toast("Made " .. players.get_name(player_id) .. "'s car " .. (value and "slow" or "normal") .."!")
    end)

    -- -- Make Drift
    menu.toggle(player_trolling_vehicle_root, "Make Drift", {"ryandrift"}, "Makes the car they are in lose grip.", function(value)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_no_grip(vehicle, value)
            end
        end
        util.toast("Made " .. players.get_name(player_id) .. "'s car " .. (value and "drift" or "no longer drift") .."!")
    end)

    -- -- Lock Doors
    menu.toggle(player_trolling_vehicle_root, "Lock Doors", {"ryanlock"}, "Locks the car they are in.", function(value)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_doors_locked(vehicle, value)
            end
        end
        util.toast((value and "Locked" or "Unlocked") .. " " .. players.get_name(player_id) .. "'s car!")
    end)

    -- -- Burst Tires
    menu.toggle(player_trolling_vehicle_root, "Burst Tires", {"ryanburst"}, "Burst the tires of the car they are in.", function(value)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_tires_bursted(vehicle, value)
            end
        end
        util.toast((value and "Bursted" or "Fixed") .. " " .. players.get_name(player_id) .. "'s tires!")
    end)

    -- -- Kill Engine
    menu.toggle(player_trolling_vehicle_root, "Kill Engine", {"ryankillengine"}, "Kills the car they are in.", function(value)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, value and -4000 or 1000)
            end
        end
        util.toast((value and "Killed" or "Revived") .. " " .. players.get_name(player_id) .. "'s car!")
    end)

    -- -- Upgrade
    menu.action(player_trolling_vehicle_root, "Upgrade", {"ryanupgrade"}, "Upgrades the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_upgraded(vehicle, true)
            end
        end
        util.toast("Upgraded " .. players.get_name(player_id) .. "'s car!")
    end)

    -- -- Downgrade
    menu.action(player_trolling_vehicle_root, "Downgrade", {"ryandowngrade"}, "Downgrades the car they are in.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_get_ped(player_id), false)
        if vehicle ~= NULL then
            entity_request_control_loop(vehicle)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                vehicle_set_upgraded(vehicle, false)
            end
        end
        util.toast("Downgraded " .. players.get_name(player_id) .. "'s car!")
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
        util.toast("Catapulted " .. players.get_name(player_id) .. "'s car!")
    end)

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
    end)

    -- -- Fake Money Drop
    menu.toggle_loop(player_trolling_root, "Fake Money Drop", {"ryanfakemoney"}, "Drops fake money bags on the player.", function()
        util.create_thread(function()
            player_fake_money_drop(player_id)
        end)
        util.yield(125)
    end, false)

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
    menu.action(player_removal_root, "Stand Kick", {"ryanstandkick"}, "Attempts to kick using Stand's Smart kick.", function()
        player_spam_and_block(player_id, removal_block_joins, removal_message, function()
            local player_name = players.get_name(player_id)
            menu.trigger_commands("kick" .. player_name)
        end)
    end)

    -- -- Omnicrash (Credit: various artists)
    menu.action(player_removal_root, "Omnicrash Mk II", {"ryanomnicrash"}, "Attempts to crash using all known script events.", function()
        player_spam_and_block(player_id, removal_block_joins, removal_message, function()
            player_omnicrash(player_id)
        end)
    end)

    -- -- Smelly Peepo Crash (Credit: 2take1 Additions, Keramis Script)
    menu.action(player_removal_root, "Smelly Peepo Crash", {"ryansmellypeepo"}, "Attempts to crash using invalid and bugged peds.", function(click_type)
        local smelly_peepo_ref = menu.ref_by_command_name("ryansmellypeepo" .. players.get_name(player_id):lower())
        menu.show_warning(smelly_peepo_ref, click_type, "If you are near this player, you will crash too.\nBe sure you are far enough away before pressing Proceed.", function()
            player_spam_and_block(player_id, removal_block_joins, removal_message, function()
                player_smelly_peepo_crash(player_id)
            end)
        end)
    end)


    -- Divorce Kick --
    menu.action(player_root, "Divorce", {"ryandivorce"}, "Kicks the player, then blocks future joins by them.", function()
        local player_name = players.get_name(player_id)
        player_block_joins(player_name)
        menu.trigger_commands("kick" .. player_name)
        menu.trigger_commands("players")
    end)
end


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
    if sender ~= players.user() then
        if kick_money_beggars then
            if (message:find("can") or message:find("?") or message:find("please") or message:find("plz") or message:find("pls"))
                and message:find("money") and message:find("drop") then
                    basics_show_text_message(Colors.Purple, "Kick Money Beggars", players.get_name(sender) .. " is being kicked for begging for money drops.")
                player_omnicrash(sender)
            end
        end
        if kick_car_meeters then
            if (message:find("want to") or message:find("wanna") or message:find("at") or message:find("?"))
                and message:find("car") and message:find("meet") then
                    basics_show_text_message(Colors.Purple, "Kick Car Meeters", players.get_name(sender) .. " is being kicked for suggesting a car meet.")
                player_omnicrash(sender)
            end
        end
    end

    if #chat_history > 25 then
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
    if crosshair_mode == CrosshairModes.Always or (crosshair_mode == CrosshairModes.WhenPointing and player_is_pointing) then
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