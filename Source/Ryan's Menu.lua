VERSION = "0.8.1b1"
MANIFEST = {
    lib = {"Audio.lua", "Basics.lua", "Entity.lua", "Globals.lua", "JSON.lua", "Natives.lua", "Player.lua", "PTFX.lua", "Session.lua", "Stats.lua", "Trolling.lua", "Vector.lua", "Vehicle.lua"},
    resources = {"Crosshair.png"}
}

Ryan = {}


-- Requirements --
function exists(name) return filesystem.exists(filesystem.scripts_dir() .. name) end
for required_directory, required_files in pairs(MANIFEST) do
    for _, required_file in pairs(required_files) do
        if not exists(required_directory .. "\\Ryan's Menu\\" .. required_file) then
            if required_file == "Basics.lua" or required_file == "JSON.lua" or required_file == "Natives.lua" then
                while not exists(required_directory .. "\\Ryan's Menu\\" .. required_file) do
                    util.toast("Ryan's Menu is missing a required file and must be reinstalled.")
                    util.yield(2000)
                end
            else
                VERSION = "-1"
            end
        elseif required_directory == 'lib' then
            require(required_directory .. "\\Ryan's Menu\\" .. required_file:sub(0, -5))
        end
    end
end


-- Check for Updates --
--if not debug.getinfo(1, "S").source:lower():find("dev") then
    updating = 1
    async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/MANIFEST", function(manifest)
        latest_version = manifest:sub(1, manifest:find("\n") - 1)
        manifest = Ryan.JSON.Decode(manifest:sub(manifest:find("\n"), manifest:len()))
        if latest_version ~= VERSION then
            util.show_corner_help("<b>Updating Ryan's Menu</b><br>Now downloading v" .. latest_version .. ". Please wait...")
            
            -- -- Download Update
            updating = 2
            local files_total, files_done = 0, 0
            for directory, files in pairs(manifest) do
                files_total = files_total + (directory == "main" and 1 or #files)
            end

            function on_update()
                util.show_corner_help("<b>Update Complete</b><br>Please restart Ryan's Menu to start using version " .. latest_version .. ".")
                Ryan.Basics.ShowTextMessage(49, "Auto-Update", "Updated! Please restart Ryan's Menu to continue.")
                menu.focus(menu.ref_by_command_name("stopluaryansmenu"))
                util.stop_script()
            end

            for directory, files in pairs(manifest) do
                if directory == "main" then
                    async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/Source/" .. files, function(contents)
                        local destination = assert(io.open(filesystem.scripts_dir() .. files, "w"))
                        destination:write(contents)
                        assert(destination:close())
                        files_done = files_done + 1
                        if files_done == files_total then on_update() end
                    end)
                    async_http.dispatch()
                else
                    filesystem.mkdirs(filesystem.scripts_dir() .. directory .. "\\" .. "Ryan's Menu")
                    for _, file in pairs(files) do
                        async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/Source/" .. directory .. "/" .. file, function(contents)
                            local destination = assert(io.open(filesystem.scripts_dir() .. directory .. "\\Ryan's Menu\\" .. file, file:find(".png") and "wb" or "w"))
                            destination:write(contents)
                            assert(destination:close())
                            files_done = files_done + 1
                            if files_done == files_total then on_update() end
                        end)
                        async_http.dispatch()
                    end
                end
            end
        else
            Ryan.Basics.ShowTextMessage(49, "Auto-Update", "You're up to date. Enjoy!")
            Ryan.Audio.PlayFromEntity(Ryan.Player.GetPed(), "GTAO_FM_Events_Soundset", "Object_Dropped_Remote")
            updating = 0
        end
    end, function()
        Ryan.Basics.ShowTextMessage(6, "Auto-Update", "Failed to get the latest version. Use the installer instead.")
    end)
    async_http.dispatch()

    while updating ~= 0 do
        if updating == 2 then util.toast("Downloading files for Ryan's Menu...") end
        util.yield(333)
    end
--end

Ryan.Basics.RequestModel(2628187989)
Ryan.Globals.CrosshairTexture = directx.create_texture(filesystem.resources_dir() .. "Ryan's Menu\\Crosshair.png")


-- Switching Sessions --
local waiting_for_session = false
local waiting_for_coords = nil
util.create_tick_handler(function()
    if not NETWORK.NETWORK_IS_SESSION_ACTIVE() then
        waiting_for_session = true
        waiting_for_coords = nil
    end
    if waiting_for_session then
        if NETWORK.NETWORK_IS_SESSION_ACTIVE() then
            waiting_for_session = false
            waiting_for_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
        end
    end
    if waiting_for_coords ~= nil then
        local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
        if Ryan.Vector.Distance(coords, waiting_for_coords) > 0.1 then
            waiting_for_coords = nil
        end
    end
end)
function is_switching_sessions()
    return waiting_for_session or waiting_for_coords ~= nil
end


-- Main Menu --
self_root = menu.list(menu.my_root(), "Self", {"ryanself"}, "Helpful options for yourself.")
world_root = menu.list(menu.my_root(), "World", {"ryanworld"}, "Helpful options for entities in the world.")
session_root = menu.list(menu.my_root(), "Session", {"ryansession"}, "Trolling options for the entire session.")
stats_root = menu.list(menu.my_root(), "Stats", {"ryanstats"}, "Common stats you may want to edit.")
chat_root = menu.list(menu.my_root(), "Chat", {"ryanchat"}, "Send special chat messages.")
settings_root = menu.list(menu.my_root(), "Settings", {"ryansettings"}, "Settings for Ryan's Menu.")


-- Self Menu --
player_is_pointing = false
entities_smashed = {}
entities_chaosed = {}
entities_exploded = {}

menu.divider(self_root, "General")
self_ptfx_root = menu.list(self_root, "PTFX...", {"ryanptfx"}, "Special FX options.")
self_fire_root = menu.list(self_root, "Fire...", {"ryanfire"}, "An enhanced LanceScript burning man.")
self_forcefield_root = menu.list(self_root, "Forcefield...", {"ryanforcefield"}, "An enhanced WiriScript forcefield.")
self_god_finger_root = menu.list(self_root, "God Finger...", {"ryangodfinger"}, "Control objects with your finger.")
self_crosshair_root = menu.list(self_root, "Crosshair...", {"ryancrosshair"}, "Add an on-screen crosshair.")

-- -- PTFX
ptfx_color = {r = 1.0, g = 1.0, b = 1.0}
ptfx_disable = false

self_ptfx_body_root = menu.list(self_ptfx_root, "Body...", {"ryanptfxbody"}, "Special FX on your body.")
self_ptfx_weapon_root = menu.list(self_ptfx_root, "Weapon...", {"ryanptfxweapon"}, "Special FX on your weapon.")
self_ptfx_vehicle_root = menu.list(self_ptfx_root, "Vehicle...", {"ryanptfxvehicle"}, "Special FX on your vehicle.")
self_ptfx_god_finger_root = menu.list(self_ptfx_root, "God Finger...", {"ryanptfxgodfinger"}, "Special FX when using God Finger.")

menu.divider(self_ptfx_root, "Options")
menu.colour(self_ptfx_root, "Color", {"ryanptfxcolor"}, "Some PTFX options allow for custom colors.", 1.0, 1.0, 1.0, 1.0, false, function(value)
    ptfx_color.r = value.r
    ptfx_color.g = value.g
    ptfx_color.b = value.b
end)
menu.toggle(self_ptfx_root, "Disable", {"ryanptfxoff"}, "Disables PTFX but keeps your settings.", function(value)
    ptfx_disable = value
end)

-- -- Body PTFX
self_ptfx_body_head_root = menu.list(self_ptfx_body_root, "Head...", {"ryanptfxhead"}, "Special FX on your head.")
self_ptfx_body_hands_root = menu.list(self_ptfx_body_root, "Hands...", {"ryanptfxhands"}, "Special FX on your hands.")
self_ptfx_body_feet_root = menu.list(self_ptfx_body_root, "Feet...", {"ryanptfxfeet"}, "Special FX on your feet.")
self_ptfx_body_pointer_root = menu.list(self_ptfx_body_root, "Pointer...", {"ryanptfxpointer"}, "Special FX on your finger when pointing.")

Ryan.PTFX.CreateList(self_ptfx_body_head_root, function(ptfx)
    if ptfx_disable then return end
    Ryan.PTFX.PlayOnEntityBones(Ryan.Player.GetPed(), Ryan.PTFX.PlayerBones.Head, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

Ryan.PTFX.CreateList(self_ptfx_body_hands_root, function(ptfx)
    if ptfx_disable then return end
    Ryan.PTFX.PlayOnEntityBones(Ryan.Player.GetPed(), Ryan.PTFX.PlayerBones.Hands, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)


Ryan.PTFX.CreateList(self_ptfx_body_feet_root, function(ptfx)
    if ptfx_disable then return end
    Ryan.PTFX.PlayOnEntityBones(Ryan.Player.GetPed(), Ryan.PTFX.PlayerBones.Feet, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

Ryan.PTFX.CreateList(self_ptfx_body_pointer_root, function(ptfx)
    if ptfx_disable then return end
    if player_is_pointing then
        Ryan.PTFX.PlayOnEntityBones(Ryan.Player.GetPed(), Ryan.PTFX.PlayerBones.Pointer, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Vehicle PTFX
self_ptfx_vehicle_wheels_root = menu.list(self_ptfx_vehicle_root, "Wheels...", {"ryanptfxwheels"}, "Special FX on the wheels of your vehicle.")
self_ptfx_vehicle_exhaust_root = menu.list(self_ptfx_vehicle_root, "Exhaust...", {"ryanptfxexhaust"}, "Speicla FX on the exhaust of your vehicle.")

Ryan.PTFX.CreateList(self_ptfx_vehicle_wheels_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(), true)
    if vehicle ~= 0 then
        Ryan.PTFX.PlayOnEntityBones(vehicle, Ryan.PTFX.VehicleBones.Wheels, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

Ryan.PTFX.CreateList(self_ptfx_vehicle_exhaust_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(), true)
    if vehicle ~= 0 then
        Ryan.PTFX.PlayOnEntityBones(vehicle, Ryan.PTFX.VehicleBones.Exhaust, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Weapon PTFX
self_ptfx_weapon_aiming_root = menu.list(self_ptfx_weapon_root, "Crosshair...", {"ryanptfxcrosshair"}, "Special FX when aiming at a spot.")
self_ptfx_weapon_muzzle_root = menu.list(self_ptfx_weapon_root, "Muzzle...", {"ryanptfxmuzzle"}, "Special FX on the end of your weapon's barrel.")
self_ptfx_weapon_muzzle_flash_root = menu.list(self_ptfx_weapon_root, "Muzzle Flash...", {"ryanptfxmuzzleflash"}, "Special FX on the end of your weapon's barrel when firing.")
self_ptfx_weapon_impact_root = menu.list(self_ptfx_weapon_root, "Impact...", {"ryanptfximpact"}, "Special FX at the impact of your bullets.")

Ryan.PTFX.CreateList(self_ptfx_weapon_aiming_root, function(ptfx)
    if ptfx_disable then return end
    if CAM.IS_AIM_CAM_ACTIVE() then
        local raycast = Ryan.Basics.Raycast(500.0)
        if raycast.did_hit then
            Ryan.PTFX.PlayAtCoords(raycast.hit_coords, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

Ryan.PTFX.CreateList(self_ptfx_weapon_muzzle_root, function(ptfx)
    if ptfx_disable then return end
    local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(Ryan.Player.GetPed())
    if weapon ~= NULL then
        Ryan.PTFX.PlayAtEntityBoneCoords(weapon, Ryan.PTFX.WeaponBones.Muzzle, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

Ryan.PTFX.CreateList(self_ptfx_weapon_muzzle_flash_root, function(ptfx)
    if ptfx_disable then return end
    local player_ped = Ryan.Player.GetPed()
    if PED.IS_PED_SHOOTING(player_ped) then
        local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(player_ped)
        if weapon ~= NULL then
            Ryan.PTFX.PlayAtEntityBoneCoords(weapon, Ryan.PTFX.WeaponBones.Muzzle, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

Ryan.PTFX.CreateList(self_ptfx_weapon_impact_root, function(ptfx)
    if ptfx_disable then return end
    local impact_ptr = memory.alloc()
    if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(Ryan.Player.GetPed(), impact_ptr) then
        Ryan.PTFX.PlayAtCoords(memory.read_vector3(impact_ptr), ptfx[2], ptfx[3], ptfx_color)
        memory.free(impact_ptr)
    end
end)

-- -- God Finger PTFX
self_ptfx_god_finger_crosshair_root = menu.list(self_ptfx_god_finger_root, "Crosshair...", {"ryanptfxgodfingercrosshair"}, "Special FX wherever you point when using God Finger.")
self_ptfx_god_finger_entities_root = menu.list(self_ptfx_god_finger_root, "Entities...", {"ryanptfxgodfingerentities"}, "Special FX only on entities when using God Finger.")

Ryan.PTFX.CreateList(self_ptfx_god_finger_crosshair_root, function(ptfx)
    if ptfx_disable then return end
    if player_is_pointing then
        local raycast = Ryan.Basics.Raycast(1000.0)
        if raycast.did_hit then
            Ryan.PTFX.PlayAtCoords(raycast.hit_coords, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

Ryan.PTFX.CreateList(self_ptfx_god_finger_entities_root, function(ptfx)
    if ptfx_disable then return end
    if god_finger_target ~= nil then
        Ryan.PTFX.PlayAtCoords(god_finger_target, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Forcefield
forcefield_mode = "Off"
forcefield_change = 2147483647
forcefield_values = {["Off"] = true}

forcefield_size = 10
forcefield_force = 1
forcefield_draw_sphere = false

for _, mode in pairs(Ryan.Globals.ForcefieldModes) do
    menu.toggle(self_forcefield_root, mode, {"ryanforcefield" .. Ryan.Basics.StringToCommandName(mode)}, "", function(value)
        if value and mode ~= forcefield_mode then
            menu.trigger_commands("ryanforcefield" .. Ryan.Basics.StringToCommandName(forcefield_mode) .. " off")
            forcefield_mode = mode
        end

        forcefield_change = util.current_time_millis()
        forcefield_values[mode] = value
    end, mode == "Off")
end

util.create_tick_handler(function()
    if util.current_time_millis() - forcefield_change > 500 then
        local has_choice = false
        for _, mode in pairs(Ryan.Globals.ForcefieldModes) do
            if forcefield_values[mode] then has_choice = true end
        end
        if not has_choice then menu.trigger_commands("ryanforcefieldoff on") end
        forcefield_change = 2147483647
    end
end)

menu.divider(self_forcefield_root, "Options")
forcefield_size_input = menu.slider(self_forcefield_root, "Size", {"ryanforcefieldsize"}, "Diameter of the forcefield sphere.", 10, 250, 10, 10, function(value)
    forcefield_size = value
end)
menu.slider(self_forcefield_root, "Force", {"ryanforcefieldforce"}, "Force applied by the forcefield.", 1, 100, 1, 1, function(value)
    forcefield_force = value
end)

menu.on_focus(forcefield_size_input, function() forcefield_draw_sphere = true end)
menu.on_blur(forcefield_size_input, function() forcefield_draw_sphere = false end)

util.create_tick_handler(function()
    if forcefield_draw_sphere then
        local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
        GRAPHICS._DRAW_SPHERE(coords.x, coords.y, coords.z, forcefield_size, esp_color.r * 255, esp_color.g * 255, esp_color.b * 255, 0.3)
    end

    if forcefield_mode ~= "Off" then
        local player_ped = Ryan.Player.GetPed()
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        local nearby = Ryan.Entity.GetAllNearby(player_coords, forcefield_size, Ryan.Entity.Type.All)
        for _, entity in pairs(nearby) do
            if forcefield_mode == "Push" then -- Push entities away
                local entity_coords = ENTITY.GET_ENTITY_COORDS(entity)
                local force = Ryan.Vector.Normalize(Ryan.Vector.Subtract(entity_coords, player_coords))
                force = Ryan.Vector.Multiply(force, forcefield_force * 0.25)
                if ENTITY.IS_ENTITY_A_PED(entity) then
                    if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                        Ryan.Entity.RequestControl(entity)
                        PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                    end
                elseif entity ~= entities.get_user_vehicle_as_handle() then
                    Ryan.Entity.RequestControl(entity)
                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif forcefield_mode == "Pull" then -- Pull entities in
                local entity_coords = ENTITY.GET_ENTITY_COORDS(entity)
                local force = Ryan.Vector.Normalize(Ryan.Vector.Subtract(player_coords, entity_coords))
                force = Ryan.Vector.Multiply(force, forcefield_force * 0.25)
                if ENTITY.IS_ENTITY_A_PED(entity) then
                    if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                        Ryan.Entity.RequestControl(entity)
                        PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                    end
                elseif entity ~= entities.get_user_vehicle_as_handle() then
                    Ryan.Entity.RequestControl(entity)
                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif forcefield_mode == "Spin" then -- Spin entities around
                if not ENTITY.IS_ENTITY_A_PED(entity) and entity ~= entities.get_user_vehicle_as_handle() then
                    Ryan.Entity.RequestControl(entity)
                    ENTITY.SET_ENTITY_HEADING(entity, ENTITY.GET_ENTITY_HEADING(entity) + 2.5 * forcefield_force)
                end
            elseif forcefield_mode == "Up" then -- Force entities into air
                local force = {x = 0, y = 0, z = 0.5 * forcefield_force}
                if ENTITY.IS_ENTITY_A_PED(entity) then
                    if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                        Ryan.Entity.RequestControl(entity)
                        PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                    end
                elseif entity ~= entities.get_user_vehicle_as_handle() then
                    Ryan.Entity.RequestControl(entity)
                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif forcefield_mode == "Down" then -- Force entities into ground
                local force = {x = 0, y = 0, z = -2 * forcefield_force}
                if ENTITY.IS_ENTITY_A_PED(entity) then
                    if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                        Ryan.Entity.RequestControl(entity)
                        PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                    end
                elseif entity ~= entities.get_user_vehicle_as_handle() then
                    Ryan.Entity.RequestControl(entity)
                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif forcefield_mode == "Smash" then -- Slam entities into ground
                local direction = util.current_time_millis() % 3000 >= 1250 and -2 or 0.5
                local force = {x = 0, y = 0, z = direction * forcefield_force}
                if ENTITY.IS_ENTITY_A_PED(entity) then
                    if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                        Ryan.Entity.RequestControl(entity)
                        PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                    end
                elseif entity ~= entities.get_user_vehicle_as_handle() then
                    Ryan.Entity.RequestControl(entity)
                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif forcefield_mode == "Chaos" then -- Chaotic entities
                if entities_chaosed[entity] == nil or util.current_time_millis() - entities_chaosed[entity] > 1000 then
                    local amount = forcefield_force * 10
                    local force = {
                        x = math.random(0, 1) == 0 and -amount or amount,
                        y = math.random(0, 1) == 0 and -amount or amount,
                        z = 0
                    }
                    if ENTITY.IS_ENTITY_A_PED(entity) then
                        if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                            Ryan.Entity.RequestControl(entity)
                            PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                            ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, false, true)
                        end
                    elseif entity ~= entities.get_user_vehicle_as_handle() then
                        Ryan.Entity.RequestControl(entity)
                        ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, false, true)
                    end
                    entities_chaosed[entity] = util.current_time_millis()
                end
            elseif forcefield_mode == "Explode" then -- Explode entities
                if entities_exploded[entity] == nil then
                    if entity ~= player_ped and entity ~= player_vehicle then
                        local coords = ENTITY.GET_ENTITY_COORDS(entity)
                        FIRE.ADD_EXPLOSION(
                            coords.x, coords.y, coords.z,
                            7, 5.0, false, true, 0.0
                        )
                    end
                    entities_exploded[entity] = true
                end
            end
        end
    end
end)

-- -- Fire
self_fire_finger_root = menu.list(self_fire_root, "Finger...", {"ryanfirefinger"}, "Catches things on fire from a distance when pressing X.")

fire_finger_mode = "Off"
fire_finger_change = 2147483647
fire_finger_values = {["Off"] = true}

for _, mode in pairs(Ryan.Globals.FireFingerModes) do
    menu.toggle(self_fire_finger_root, mode, {"ryanfirefinger" .. Ryan.Basics.StringToCommandName(mode)}, "", function(value)
        if value then
            if mode ~= fire_finger_mode then
                menu.trigger_commands("ryanfirefinger" .. Ryan.Basics.StringToCommandName(fire_finger_mode) .. " off")
            end
            fire_finger_mode = mode
        end

        fire_finger_change = util.current_time_millis()
        fire_finger_values[mode] = value
    end, mode == "Off")
end
util.create_tick_handler(function()
    if util.current_time_millis() - fire_finger_change > 500 then
        local has_choice = false
        for _, mode in pairs(Ryan.Globals.FireFingerModes) do
            if fire_finger_values[mode] then has_choice = true end
        end
        if not has_choice then menu.trigger_commands("ryanfirefingeroff on") end
        fire_finger_change = 2147483647
    end
end)

menu.toggle(self_fire_root, "Body", {"ryanfirebody"}, "Sets yourself on fire visually.", function(value)
    if value then
        menu.trigger_commands("demigodmode on")
        FIRE.START_ENTITY_FIRE(Ryan.Player.GetPed())
    else
        menu.trigger_commands("demigodmode off")
        FIRE.STOP_ENTITY_FIRE(Ryan.Player.GetPed())
    end
end)

fire_finger_last_coords = {x = 0, y = 0, z = 0}
menu.toggle_loop(self_fire_root, "Touch", {"ryanfiretouch"}, "Catches things on fire when you touch them.", function(value)
    local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
    if Ryan.Vector.Distance(coords, fire_finger_last_coords) > 1.5 then
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 3, 100.0, false, false, 1.0)
        fire_finger_last_coords = coords
    end
    util.yield(500)
end)

util.create_tick_handler(function()
    if fire_finger_mode == "Always" or (fire_finger_mode == "When Pointing" and player_is_pointing) then
        if PAD.IS_CONTROL_JUST_PRESSED(21, Ryan.Globals.Controls.Duck) then
            local raycast = Ryan.Basics.Raycast(250.0)
            if raycast.did_hit then
                FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 3, 100.0, false, false, 0.0)
            end
        end
    end
end)

-- -- God Finger
self_god_finger_mode_root = menu.list(self_god_finger_root, "Force", {"ryangodfingerforce"}, "The type of force to apply, if any.")

god_finger_mode = "Off"
god_finger_change = 2147483647
god_finger_values = {["Off"] = true}

god_finger_target = nil
god_finger_gravity = false
god_finger_steal = false
god_finger_while_pointing = true
god_finger_while_pressing_e = false
god_finger_while_pressing_x = false

for _, mode in pairs(Ryan.Globals.GodFingerModes) do
    menu.toggle(self_god_finger_mode_root, mode, {"ryangodfingerforce" .. Ryan.Basics.StringToCommandName(mode)}, "", function(value)
        if value then
            if mode ~= god_finger_mode then
                menu.trigger_commands("ryangodfingerforce" .. Ryan.Basics.StringToCommandName(god_finger_mode) .. " off")
            end
            god_finger_mode = mode
        end

        god_finger_change = util.current_time_millis()
        god_finger_values[mode] = value
    end, mode == "Off")
end
util.create_tick_handler(function()
    if util.current_time_millis() - god_finger_change > 500 then
        local has_choice = false
        for _, mode in pairs(Ryan.Globals.GodFingerModes) do
            if god_finger_values[mode] then has_choice = true end
        end
        if not has_choice then menu.trigger_commands("ryangodfingerforceoff on") end
        god_finger_change = 2147483647
    end
end)

menu.toggle(self_god_finger_root, "Anti-Gravity", {"ryangodfingergravity"}, "Takes away object gravity when God Fingered.", function(value)
    god_finger_gravity = value
end)

menu.toggle(self_god_finger_root, "Steal Vehicle", {"ryangodfingersteal"}, "Steals any vehicle you God Finger.", function(value)
    god_finger_steal = value
end)

menu.divider(self_god_finger_root, "Activate")
menu.toggle(self_god_finger_root, "While Pointing", {"ryangodfingerpointing"}, "If enabled, god finger activates while pointing.", function(value)
    god_finger_while_pointing = value
end, true)

menu.toggle(self_god_finger_root, "While Pressing E", {"ryangodfingerpressinge"}, "If enabled, god finger activates while holding the E key / left stick.", function(value)
    god_finger_while_pressing_e = value
end)

menu.toggle(self_god_finger_root, "While Pressing X", {"ryangodfingerpressingx"}, "If enabled, god finger activates while holding the X key / A button.", function(value)
    god_finger_while_pressing_x = value
end)

util.create_tick_handler(function()
    for entity, start_time in pairs(entities_smashed) do
        local time_elapsed = util.current_time_millis() - start_time
        if time_elapsed < 2500 then
            local direction = time_elapsed > 1250 and -3 or 0.5
            local force = {x = 0, y = 0, z = direction * 4}
            if ENTITY.IS_ENTITY_A_PED(entity) then
                if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                    PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif entity ~= entities.get_user_vehicle_as_handle() then
                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        end
    end

    ENTITY.SET_ENTITY_PROOFS(Ryan.Player.GetPed(), false, false, god_finger_mode == "Default", false, false, false, 1, false)

    if not (god_finger_while_pointing and player_is_pointing)
    and not (god_finger_while_pressing_x and PAD.IS_CONTROL_PRESSED(21, Ryan.Globals.Controls.Duck))
    and not (god_finger_while_pressing_e and PAD.IS_CONTROL_PRESSED(21, Ryan.Globals.Controls.Horn)) then
        
        god_finger_target = nil;
        return
    end

    local raycast = Ryan.Basics.Raycast(500.0, 2 + 8 + 16)
    memory.write_int(memory.script_global(4516656 + 935), NETWORK.GET_NETWORK_TIME())
    if raycast.did_hit and raycast.hit_entity ~= nil then
        god_finger_target = raycast.hit_coords
        Ryan.Entity.DrawESP(raycast.hit_entity, esp_color)

        if god_finger_steal and ENTITY.IS_ENTITY_A_VEHICLE(raycast.hit_entity) then
            Ryan.Vehicle.Steal(raycast.hit_entity)
            return
        end
        
        if god_finger_gravity then
            ENTITY.SET_ENTITY_HAS_GRAVITY(raycast.hit_entity, false)
            VEHICLE.SET_VEHICLE_GRAVITY(raycast.hit_entity, false)
        end

        if god_finger_mode == "Default" then
            FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 29, 25.0, false, true, 0.0, true)
        elseif god_finger_mode == "Push" then -- Push entities away
            local entity_coords = ENTITY.GET_ENTITY_COORDS(raycast.hit_entity)
            local force = Ryan.Vector.Normalize(Ryan.Vector.Subtract(entity_coords, ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())))
            force = Ryan.Vector.Multiply(force, 0.4)
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Ryan.Entity.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif raycast.hit_entity ~= entities.get_user_vehicle_as_handle() then
                Ryan.Entity.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif god_finger_mode == "Pull" then -- Pull entities in
            local entity_coords = ENTITY.GET_ENTITY_COORDS(raycast.hit_entity)
            local force = Ryan.Vector.Normalize(Ryan.Vector.Subtract(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed()), entity_coords))
            force = Ryan.Vector.Multiply(force, 0.4)
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Ryan.Entity.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif raycast.hit_entity ~= entities.get_user_vehicle_as_handle() then
                Ryan.Entity.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif god_finger_mode == "Smash" then -- Smash entities
            if entities_smashed[raycast.hit_entity] == nil or util.current_time_millis() - entities_smashed[raycast.hit_entity] > 2500 then
                Ryan.Entity.RequestControl(raycast.hit_entity)
                entities_smashed[raycast.hit_entity] = util.current_time_millis()
            end
        elseif god_finger_mode == "Chaos" then -- Chaotic entities
            if entities_chaosed[raycast.hit_entity] == nil or util.current_time_millis() - entities_chaosed[raycast.hit_entity] > 1000 then
                local amount = 20
                local force = {
                    x = math.random(0, 1) == 0 and -amount or amount,
                    y = math.random(0, 1) == 0 and -amount or amount,
                    z = 0
                }
                if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                    if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                        Ryan.Entity.RequestControl(raycast.hit_entity)
                        PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                        ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, false, true)
                    end
                elseif raycast.hit_entity ~= entities.get_user_vehicle_as_handle() then
                    Ryan.Entity.RequestControl(raycast.hit_entity)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, false, true)
                end
                entities_chaosed[raycast.hit_entity] = util.current_time_millis()
            end
        elseif god_finger_mode == "Explode" then -- Explode entities
            if entities_exploded[raycast.hit_entity] == nil then
                local coords = ENTITY.GET_ENTITY_COORDS(raycast.hit_entity)
                FIRE.ADD_EXPLOSION(
                    coords.x, coords.y, coords.z,
                    7, 100.0, false, true, 0.0
                )
                entities_exploded[raycast.hit_entity] = true
            end
        end
    else
        god_finger_target = nil
    end
end)

-- -- Crosshair
crosshair_mode = "Off"
crosshair_change = 2147483647
crosshair_values = {["Off"] = true}

for _, mode in pairs(Ryan.Globals.CrosshairModes) do
    menu.toggle(self_crosshair_root, mode, {"ryancrosshair" .. Ryan.Basics.StringToCommandName(mode)}, "", function(value)
        if value then
            if mode ~= crosshair_mode then
                menu.trigger_commands("ryancrosshair" .. Ryan.Basics.StringToCommandName(crosshair_mode) .. " off")
            end
            crosshair_mode = mode
        end

        crosshair_change = util.current_time_millis()
        crosshair_values[mode] = value
    end, mode == "Off")
end

util.create_tick_handler(function()
    if util.current_time_millis() - crosshair_change > 500 then
        local has_choice = false
        for _, mode in pairs(Ryan.Globals.CrosshairModes) do
            if crosshair_values[mode] then has_choice = true end
        end
        if not has_choice then menu.trigger_commands("ryancrosshairoff on") end
        crosshair_change = 2147483647
    end
end)

menu.divider(self_root, "Vehicle")

-- -- Seats
self_seats_root = menu.list(self_root, "Seats...", {"ryanseats"}, "Allows you to switch seats in your current vehicle.")

function seat_name(i) return (i == -1 and "Driver" or "Seat " .. (i + 2)) end

switch_seats_actions = {}
switch_seats_notice = nil
util.create_tick_handler(function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed())
    if vehicle ~= 0 then
        local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(players.get_vehicle_model(players.user()))
        if seats ~= #switch_seats_actions then
            for _, action in pairs(switch_seats_actions) do menu.delete(action) end
            switch_seats_actions = {}
            for seat = -1, seats - 2 do
                table.insert(switch_seats_actions, menu.action(self_seats_root, seat_name(seat), {"ryanseat" .. (seat + 2)}, "Switches to the seat.", function()
                    PED.SET_PED_INTO_VEHICLE(Ryan.Player.GetPed(), vehicle, seat)
                end))
            end
        else
            for seat = -1, seats - 2 do
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, seat) ~= 0 then
                    menu.set_menu_name(switch_seats_actions[seat + 2], seat_name(seat) .. " [Taken]")
                else
                    menu.set_menu_name(switch_seats_actions[seat + 2], seat_name(seat))
                end
            end
        end

        if switch_seats_notice ~= nil then
            menu.delete(switch_seats_notice)
            switch_seats_notice = nil
        end
    else
        for _, action in pairs(switch_seats_actions) do menu.delete(action) end
        switch_seats_actions = {}

        if switch_seats_notice == nil then
            switch_seats_notice = menu.divider(self_seats_root, "Vehicle Needed")
        end
    end
    util.yield(200)
end)

-- -- Strafe Run
self_strafe_run_root = menu.list(self_root, "Strafe Run...", {"ryanstraferun"}, "Explodes entities the ground while you drive or fly.")

strafe_run_enabled = false
strafe_run_radius = 5
strafe_run_draw_sphere = false

menu.toggle(self_strafe_run_root, "Enabled", {"ryanstraferunenabled"}, "Enables the strafe run when pressing the Shift key / A button.", function(value)
    strafe_run_enabled = value
end)
strafe_run_radius_input = menu.slider(self_strafe_run_root, "Radius", {"ryanstraferunradius"}, "The radius in which entities on the ground will be exploded.", 1, 50, 5, 1, function(value)
    strafe_run_radius = value
end)

menu.on_focus(strafe_run_radius_input, function() strafe_run_draw_sphere = true end)
menu.on_blur(strafe_run_radius_input, function() strafe_run_draw_sphere = false end)

util.create_tick_handler(function()
    local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())

    if strafe_run_enabled or strafe_run_draw_sphere then
        local ground_z_ptr = memory.alloc(4)
        MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, coords.z, ground_z_ptr, false)
        coords.z = memory.read_float(ground_z_ptr); memory.free(ground_z_ptr)
    end

    if strafe_run_enabled then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(), false)
        if vehicle ~= 0 and PAD.IS_CONTROL_PRESSED(21, Ryan.Globals.Controls.Sprint) then
            local z = coords.z; coords = ENTITY.GET_ENTITY_COORDS(vehicle); coords.z = z
            for _, entity in pairs(Ryan.Entity.GetAllNearby(coords, strafe_run_radius, Ryan.Entity.Type.All)) do
                local entity_coords = ENTITY.GET_ENTITY_COORDS(entity)
                FIRE.ADD_EXPLOSION(
                    entity_coords.x, entity_coords.y, entity_coords.z,
                    29, 100.0, false, true, 0.0
                )
            end
        end
    end

    if strafe_run_draw_sphere then
        GRAPHICS._DRAW_SPHERE(coords.x, coords.y, coords.z, strafe_run_radius, esp_color.r * 255, esp_color.g * 255, esp_color.b * 255, 0.3)
    end
end)

-- -- E-Brake
ebrake = false
menu.toggle(self_root, "E-Brake", {"ryanebrake"}, "Makes your car drift while holding Shift.", function(value)
    if not value then Ryan.Vehicle.SetNoGrip(vehicle, false) end
    ebrake = value
end)

util.create_tick_handler(function()
    if ebrake then
        local player_ped = Ryan.Player.GetPed(players.user())
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
        if vehicle ~= 0 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) == player_ped then
            Ryan.Vehicle.SetNoGrip(vehicle, PAD.IS_CONTROL_PRESSED(21, Ryan.Globals.Controls.Sprint))
        end
    end
end)


-- World Menu --
menu.divider(world_root, "General")
world_spotlight_root = menu.list(world_root, "Spotlight...", {"ryanspotlight"}, "Makes your vehicle glow.")
world_collectibles_root = menu.list(world_root, "Collectibles...", {"ryancollectibles"}, "Useful presets to teleport to.")
world_all_npcs_root = menu.list(world_root, "All NPCs...", {"ryanallnpcs"}, "Changes the action NPCs are currently performing.")


-- -- Spotlight
spotlight_offset = 3.0
spotlight_intensity = 1

menu.action(world_spotlight_root, "Add To Body", {"ryanspotlightbody"}, "Adds spotlights to your body.", function()
    local player_ped = Ryan.Player.GetPed()
    if player_ped ~= 0 then Ryan.Entity.AddSpotlight(player_ped, spotlight_offset, spotlight_intensity) end
end)

menu.action(world_spotlight_root, "Add To Vehicle", {"ryanspotlightvehicle"}, "Adds spotlights to your vehicle.", function()
    local player_id, player_ped = players.user(), Ryan.Player.GetPed()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= 0 then Ryan.Entity.AddSpotlight(vehicle, spotlight_offset, spotlight_intensity) end
end)

menu.divider(world_spotlight_root, "Options")
menu.slider(world_spotlight_root, "Offset", {"ryanspotlightoffset"}, "How far the lights are away from the model.", 1, 100, 30, 1, function(value)
    spotlight_offset = value / 10.0
end)
menu.slider(world_spotlight_root, "Intensity", {"ryanspotlightintensity"}, "How bright the light is.", 1, 50, 1, 1, function(value)
    spotlight_intensity = value
end)

-- -- Collectibles
world_action_figures_root = menu.list(world_collectibles_root, "Action Figures...", {"ryanactionfigures"}, "Every action figure in the game.")
world_signal_jammers_root = menu.list(world_collectibles_root, "Signal Jammers...", {"ryansignaljammers"}, "Every signal jammer in the game.")
world_playing_cards_root = menu.list(world_collectibles_root, "Playing Cards...", {"ryanplayingcards"}, "Every playing card in the game.")

-- -- Action Figures
for i = 1, #Ryan.Globals.ActionFigures do
    menu.action(world_action_figures_root, "Action Figure " .. i, {"ryanactionfigure" .. i}, "Teleports to action figure #" .. i, function()
        Ryan.Player.Teleport({x = Ryan.Globals.ActionFigures[i][1], y = Ryan.Globals.ActionFigures[i][2], z = Ryan.Globals.ActionFigures[i][3]})
    end)
end

-- -- Signal Jammers
for i = 1, #Ryan.Globals.SignalJammers do
    menu.action(world_signal_jammers_root, "Signal Jammer " .. i, {"ryansignaljammer" .. i}, "Teleports to signal jammer #" .. i, function()
        Ryan.Player.TeleportWithVehicle({x = Ryan.Globals.SignalJammers[i][1], y = Ryan.Globals.SignalJammers[i][2], z = Ryan.Globals.SignalJammers[i][3]})
    end)
end

-- -- Playing Cards
for i = 1, #Ryan.Globals.PlayingCards do
    menu.action(world_playing_cards_root, "Playing Card " .. i, {"ryanplayingcard" .. i}, "Teleports to playing card #" .. i, function()
        Ryan.Player.TeleportWithVehicle({x = Ryan.Globals.PlayingCards[i][1], y = Ryan.Globals.PlayingCards[i][2], z = Ryan.Globals.PlayingCards[i][3]})
    end)
end

-- -- All NPCs
all_npcs_mode = "Off"
all_npcs_change = 2147483647
all_npcs_values = {["Off"] = true}

all_npcs_include_vehicles = false

for _, mode in pairs(Ryan.Globals.NPCScenarios) do
    menu.toggle(world_all_npcs_root, mode, {"ryanallnpcs" .. mode}, "", function(value)
        if value then
            if mode ~= all_npcs_mode then
                menu.trigger_commands("ryanallnpcs" .. all_npcs_mode .. " off")
                all_npcs_mode = mode
            end
        end
        all_npcs_change = util.current_time_millis()
        all_npcs_values[mode] = value
    end, mode == "Off")
end

util.create_tick_handler(function()
    if util.current_time_millis() - all_npcs_change > 500 then
        local has_choice = false
        for _, mode in pairs(Ryan.Globals.NPCScenarios) do
            if all_npcs_values[mode] then has_choice = true end
        end
        if not has_choice then menu.trigger_commands("ryanallnpcsoff on") end
        all_npcs_change = 2147483647
    end
end)

menu.divider(world_all_npcs_root, "Options")
menu.toggle(world_all_npcs_root, "Include Vehicles", {"ryanallnpcsvehicles"}, "If enabled, NPCs will get out of their cars.", function(value)
    all_npcs_include_vehicles = value
end, false)

npcs_affected = {}
util.create_tick_handler(function()
    if all_npcs_mode ~= "Off" then
        local scenario = ""
        if all_npcs_mode == "Musician" then scenario = "WORLD_HUMAN_MUSICIAN"
        elseif all_npcs_mode == "Human Statue" then scenario = "WORLD_HUMAN_HUMAN_STATUE"
        elseif all_npcs_mode == "Paparazzi" then scenario = "WORLD_HUMAN_PAPARAZZI"
        elseif all_npcs_mode == "Janitor" then scenario = "WORLD_HUMAN_JANITOR" end

        local player_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
        for _, ped in pairs(Ryan.Entity.GetAllNearby(player_coords, 250, Ryan.Entity.Type.Peds)) do
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            if not PED.IS_PED_A_PLAYER(ped) and (all_npcs_include_vehicles or vehicle == 0) then
                if npcs_affected[ped] ~= all_npcs_mode then
                    if all_npcs_mode == "Nude" then
                        local heading = ENTITY.GET_ENTITY_HEADING(ped)
                        local coords = ENTITY.GET_ENTITY_COORDS(ped)

                        local is_beach_model = false
                        for i = 1, #Ryan.Globals.BeachPeds do
                            if PED.IS_PED_MODEL(ped, Ryan.Globals.BeachPeds[i]) then util.toast("Found beach model"); is_beach_model = true end
                        end
                        entities.delete_by_handle(ped)
                        ped = entities.create_ped(0, util.joaat("a_f_y_topless_01"), coords, heading)
                        PED.SET_PED_COMPONENT_VARIATION(ped, 8, 1, -1, 0)
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)

                        local beach_tasks, task = {"WORLD_HUMAN_SUNBATHE", "WORLD_HUMAN_SUNBATHE_BACK"}, math.random(1, 3)
                        if not is_beach_model or task == 3 then TASK.TASK_WANDER_STANDARD(ped, 10.0, 10)
                        else TASK.TASK_START_SCENARIO_IN_PLACE(ped, beach_tasks[task], 0, false) end
                    elseif all_npcs_mode == "Delete" then
                        if vehicle ~= 0 then entities.delete_by_handle(vehicle) end
                        entities.delete_by_handle(ped)
                    else
                        if vehicle ~= 0 then ENTITY.SET_ENTITY_VELOCITY(vehicle, 0.0, 0.0, 0.0) end
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                        TASK.TASK_START_SCENARIO_IN_PLACE(ped, scenario, 0, false)
                    end
                    npcs_affected[ped] = all_npcs_mode
                end
            end
        end
    end
    util.yield(250)
end)

-- -- No Cops
menu.toggle_loop(world_root, "No Cops", {"ryannocops"}, "Clears the area of cops while enabled.", function()
    local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, 500, 0) -- might as well
    for _, entity in pairs(Ryan.Entity.GetAllNearby(coords, 500, Ryan.Entity.Type.All)) do
        if ENTITY.IS_ENTITY_A_PED(entity) then
            for _, ped_type in pairs(Ryan.Globals.PolicePedTypes) do
                if PED.GET_PED_TYPE(entity) == ped_type then
                    Ryan.Entity.RequestControl(entity)
                    entities.delete_by_handle(entity)
                end
            end
        elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            for _, vehicle_model in pairs(Ryan.Globals.PoliceVehicles) do
                if VEHICLE.IS_VEHICLE_MODEL(entity, vehicle_model) then
                    Ryan.Entity.RequestControl(entity)
                    entities.delete_by_handle(entity)
                end
            end
        end
    end
    util.yield(250)
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

-- -- Fireworks
function do_fireworks(burst_type, coords, color)
    if firework_coords == nil then return end

    coords = Ryan.Vector.Add(firework_coords, coords)
    local ptfx = nil
    for _, ptfx_data in pairs(Ryan.Globals.PTFX) do
        if ptfx_data[1] == burst_type then ptfx = ptfx_data end
    end
    Ryan.PTFX.PlayAtCoords(coords, ptfx[2], ptfx[3], color)
    Ryan.Audio.PlayAtCoords(coords, "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 100)
    Ryan.Audio.PlayAtCoords(Ryan.Vector.Add(coords, {x = 50, y = 50, z = 0}), "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 500)
    Ryan.Audio.PlayAtCoords(Ryan.Vector.Add(coords, {x = -50, y = -50, z = 0}), "WEB_NAVIGATION_SOUNDS_PHONE", "CLICK_BACK", 500)
    Ryan.Audio.PlayAtCoords(Ryan.Vector.Add(coords, {x = 75, y = 75, z = 0}), "PLAYER_SWITCH_CUSTOM_SOUNDSET", "Hit_Out", 100)
end

firework_coords = nil
menu.toggle(world_root, "Fireworks Show", {"ryanfireworkshow"}, "A nice display of liberty where you're standing. May trigger crash protections.", function(value)
    firework_coords = value and ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed()) or nil
end)
util.create_tick_handler(function()
    if firework_coords ~= nil then
        local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
        do_fireworks("Firework Burst", {x = math.random(-150, 150), y = math.random(-200, 50), z = math.random(-25, 25)}, color)

        if math.random(1, 10) == 2 then
            local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
            local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
            do_fireworks("Firework Burst", Ryan.Vector.Add(offset, {x = 8, y = 8, z = 0}), color)
            do_fireworks("Firework Burst", Ryan.Vector.Add(offset, {x = -8, y = 8, z = 0}), color)
            do_fireworks("Firework Burst", Ryan.Vector.Add(offset, {x = 8, y = -8, z = 0}), color)
            do_fireworks("Firework Burst", Ryan.Vector.Add(offset, {x = -8, y = -8, z = 0}), color)
        end
        if math.random(1, 10) == 8 then
            local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
            local color = {r = math.random(0, 255) / 255.0, g = math.random(0, 255) / 255.0, b = math.random(0, 255) / 255.0}
            for i = 1, math.random(3, 6) do
                util.yield(math.random(75, 500))
                do_fireworks("Firework Burst", Ryan.Vector.Add(offset, {x = 8, y = i + 8, z = 0}), color)
                do_fireworks("Firework Burst", Ryan.Vector.Add(offset, {x = 8, y = -i - 8, z = 0}), color)
            end
        end

        util.yield(math.random(150, 650))
    end
end)

-- -- All Entities Visible
menu.toggle_loop(world_root, "All Entities Visible", {"ryannoinvisible"}, "Makes all invisible entities visible again.", function()
    for _, player_id in pairs(players.list()) do
        local player_ped = Ryan.Player.GetPed(player_id)
        ENTITY.SET_ENTITY_ALPHA(player_ped, 255)
        ENTITY.SET_ENTITY_VISIBLE(player_ped, true, 0)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
        if vehicle ~= 0 then
            ENTITY.SET_ENTITY_ALPHA(vehicle, 255)
            ENTITY.SET_ENTITY_VISIBLE(vehicle, true, 0)
        end
    end
end)

menu.divider(world_root, "Vehicle")
world_closest_vehicle_root = menu.list(world_root, "Closest Vehicle...", {"ryanclosestvehicle"}, "Useful options for nearby vehicles.")
world_all_vehicles_root = menu.list(world_root, "All Vehicles...", {"ryanallvehicles"}, "Control the vehicles around you.")

-- -- Enter Closest Vehicle
menu.action(world_closest_vehicle_root, "Enter", {"ryandrivevehicle"}, "Teleports into the closest vehicle.", function()
    local closest_vehicle = Ryan.Vehicle.GetClosest(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(), true))
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(closest_vehicle, -1)
    
    if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, -1) then
        PED.SET_PED_INTO_VEHICLE(Ryan.Player.GetPed(), closest_vehicle, -1)
        util.toast("Teleported into the closest vehicle.")
    else
        if PED.GET_PED_TYPE(driver) >= 4 then
            entities.delete(driver)
            PED.SET_PED_INTO_VEHICLE(Ryan.Player.GetPed(), closest_vehicle, -1)
            util.toast("Teleported into the closest vehicle.")
        elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(closest_vehicle) then
            for i=0, 10 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, i) then
                    PED.SET_PED_INTO_VEHICLE(Ryan.Player.GetPed(), closest_vehicle, i)
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
    local closest_vehicle = Ryan.Vehicle.GetClosest(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(), true))
    Ryan.Entity.RequestControlLoop(closest_vehicle)
    Ryan.Vehicle.SetFullyUpgraded(closest_vehicle, true)
    util.toast("Upgraded the nearest car!")
end)

-- -- Downgrade Closest Vehicle
menu.action(world_closest_vehicle_root, "Downgrade", {"ryandowngradevehicle"}, "Downgrades the closest vehicle.", function()
    local closest_vehicle = Ryan.Vehicle.GetClosest(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(), true))
    Ryan.Entity.RequestControlLoop(closest_vehicle)
    Ryan.Vehicle.SetFullyUpgraded(closest_vehicle, false)
    util.toast("Downgraded the nearest car!")
end)

-- -- All Vehicles
all_vehicles_include_npcs = true
all_vehicles_include_players = false
all_vehicles_include_own = false

all_vehicles_speed = nil
all_vehicles_grip = nil
all_vehicles_doors = nil
all_vehicles_tires = nil
all_vehicles_engine = nil
all_vehicles_upgrades = nil

all_vehicles_catapult = false
all_vehicles_alarm = false
all_vehicles_flee = false
all_vehicles_blind = false
all_vehicles_delete = false

menu.toggle(world_all_vehicles_root, "Include NPCs", {"ryanallvehiclesnpcs"}, "If enabled, player-driven vehicles are affected too.", function(value)
    all_vehicles_include_npcs = value
end, true)
menu.toggle(world_all_vehicles_root, "Include Players", {"ryanallvehiclesplayers"}, "If enabled, player-driven vehicles are affected too.", function(value)
    all_vehicles_include_players = value
end)
menu.toggle(world_all_vehicles_root, "Include Own Vehicle", {"ryanallvehiclesown"}, "If enabled, your current vehicle is affected too.", function(value)
    all_vehicles_include_own = value
end)

menu.divider(world_all_vehicles_root, "Options")

-- -- Speed
local all_vehicles_speed_root = menu.list(world_all_vehicles_root, "Speed: -", {"ryanallspeed"}, "Changes the speed of all vehicles.")
menu.toggle(all_vehicles_speed_root, "Fast", {"ryanallspeedfast"}, "Makes the speed extremely fast.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallspeednormal off",
            "ryanallspeedslow off"
        })
        util.yield(250)
        all_vehicles_speed = "fast"
        menu.set_menu_name(all_vehicles_speed_root, "Speed: Fast")
    else
        all_vehicles_speed = nil
        menu.set_menu_name(all_vehicles_speed_root, "Speed: -")
    end
end)
menu.toggle(all_vehicles_speed_root, "Slow", {"ryanallspeedslow"}, "Makes the speed extremely slow.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallspeedfast off",
            "ryanallspeednormal off"
        })
        util.yield(250)
        all_vehicles_speed = "slow"
        menu.set_menu_name(all_vehicles_speed_root, "Speed: Slow")
    else
        all_vehicles_speed = nil
        menu.set_menu_name(all_vehicles_speed_root, "Speed: -")
    end
end)
menu.toggle(all_vehicles_speed_root, "Normal", {"ryanallspeednormal"}, "Makes the speed normal again.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallspeedfast off",
            "ryanallspeedslow off"
        })
        util.yield(250)
        all_vehicles_speed = "normal"
        menu.set_menu_name(all_vehicles_speed_root, "Speed: Normal")
    else
        all_vehicles_speed = nil
        menu.set_menu_name(all_vehicles_speed_root, "Speed: -")
    end
end)

-- -- Grip
local all_vehicles_grip_root = menu.list(world_all_vehicles_root, "Grip: -", {"ryanallgrip"}, "Changes the grip of all vehicles' wheels.")
menu.toggle(all_vehicles_grip_root, "None", {"ryanallgripnone"}, "Makes the tires have no grip.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallgripfull off"
        })
        util.yield(250)
        all_vehicles_grip = "none"
        menu.set_menu_name(all_vehicles_grip_root, "Grip: None")
    else
        all_vehicles_grip = nil
        menu.set_menu_name(all_vehicles_grip_root, "Grip: -")
    end
end)
menu.toggle(all_vehicles_grip_root, "Full", {"ryanallgripfull"}, "Makes the grip normal again.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallgripnone off"
        })
        util.yield(250)
        all_vehicles_grip = "full"
        menu.set_menu_name(all_vehicles_grip_root, "Grip: Full")
    else
        all_vehicles_grip = nil
        menu.set_menu_name(all_vehicles_grip_root, "Grip: -")
    end
end)

-- -- Doors
local all_vehicles_doors_root = menu.list(world_all_vehicles_root, "Doors: -", {"ryanalldoors"}, "Changes all vehicles' door lock state.")
menu.toggle(all_vehicles_doors_root, "Lock", {"ryanalldoorslock"}, "Locks the vehicle's doors.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanalldoorsunlock off"
        })
        util.yield(250)
        all_vehicles_doors = "lock"
        menu.set_menu_name(all_vehicles_doors_root, "Doors: Lock")
    else
        all_vehicles_doors = nil
        menu.set_menu_name(all_vehicles_doors_root, "Doors: -")
    end
end)
menu.toggle(all_vehicles_doors_root, "Unlock", {"ryanalldoorsunlock"}, "Unlocks the vehicle's doors.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanalldoorslock off"
        })
        util.yield(250)
        all_vehicles_doors = "unlock"
        menu.set_menu_name(all_vehicles_doors_root, "Doors: Unlock")
    else
        all_vehicles_doors = nil
        menu.set_menu_name(all_vehicles_doors_root, "Doors: -")
    end
end)

-- -- Tires
local all_vehicles_tires_root = menu.list(world_all_vehicles_root, "Tires: -", {"ryanalltires"}, "Changes all vehicles' tire health.")
menu.toggle(all_vehicles_tires_root, "Burst", {"ryanalltiresburst"}, "Makes the vehicle's tires burst.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanalltiresfix off"
        })
        util.yield(250)
        all_vehicles_tires = "burst"
        menu.set_menu_name(all_vehicles_tires_root, "Tires: Burst")
    else
        all_vehicles_tires = nil
        menu.set_menu_name(all_vehicles_tires_root, "Tires: -")
    end
end)
menu.toggle(all_vehicles_tires_root, "Fix", {"ryanalltiresfix"}, "Fixes the vehicle's tires.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanalltiresburst off"
        })
        util.yield(250)
        all_vehicles_tires = "fix"
        menu.set_menu_name(all_vehicles_tires_root, "Tires: Fix")
    else
        all_vehicles_tires = nil
        menu.set_menu_name(all_vehicles_tires_root, "Tires: -")
    end
end)

-- -- Engine
local all_vehicles_engine_root = menu.list(world_all_vehicles_root, "Engine: -", {"ryanallengine"}, "Changes all vehicles' engine health.")
menu.toggle(all_vehicles_engine_root, "Kill", {"ryanallenginekill"}, "Makes the vehicle's engine die.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallenginefix off"
        })
        util.yield(250)
        all_vehicles_engine = "kill"
        menu.set_menu_name(all_vehicles_engine_root, "Engine: Kill")
    else
        all_vehicles_engine = nil
        menu.set_menu_name(all_vehicles_engine_root, "Engine: -")
    end
end)
menu.toggle(all_vehicles_engine_root, "Fix", {"ryanallenginefix"}, "Fixes the vehicle's engine.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallenginekill off"
        })
        util.yield(250)
        all_vehicles_engine = "fix"
        menu.set_menu_name(all_vehicles_engine_root, "Engine: Fix")
    else
        all_vehicles_engine = nil
        menu.set_menu_name(all_vehicles_engine_root, "Engine: -")
    end
end)

-- -- Upgrades
local all_vehicles_upgrades_root = menu.list(world_all_vehicles_root, "Upgrades: -", {"ryanallupgrades"}, "Changes all vehicles' upgrades.")
menu.toggle(all_vehicles_upgrades_root, "All", {"ryanallupgradesall"}, "Fully upgrades the vehicle.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallupgradesnone off"
        })
        util.yield(250)
        all_vehicles_upgrades = "all"
        menu.set_menu_name(all_vehicles_upgrades_root, "Upgrades: All")
    else
        all_vehicles_upgrades = nil
        menu.set_menu_name(all_vehicles_upgrades_root, "Upgrades: -")
    end
end)
menu.toggle(all_vehicles_upgrades_root, "None", {"ryanallupgradesnone"}, "Fully downgrades the vehicle.", function(value)
    if value then
        Ryan.Basics.RunCommands({
            "ryanallupgradesall off"
        })
        util.yield(250)
        all_vehicles_upgrades = "none"
        menu.set_menu_name(all_vehicles_upgrades_root, "Upgrades: None")
    else
        all_vehicles_upgrades = nil
        menu.set_menu_name(all_vehicles_upgrades_root, "Upgrades: -")
    end
end)

-- -- Catapult
menu.toggle(world_all_vehicles_root, "Catapult", {"ryanallcatapult"}, "Catapults their vehicle non-stop.", function(value)
    all_vehicles_catapult = value
end)

-- -- Alarm
menu.toggle(world_all_vehicles_root, "Alarm", {"ryanallalarm"}, "Triggers their vehicle's theft alarm.", function(value)
    all_vehicles_alarm = value
end)

-- -- Flee
menu.toggle(world_all_vehicles_root, "Flee", {"ryanallflee"}, "Makes NPCs flee you.", function(value)
    all_vehicles_flee = value
end)

-- -- Road Rage
menu.toggle(world_all_vehicles_root, "Blind", {"ryanallblind"}, "Makes NPCs drive without regard for what's around them.", function(value)
    all_vehicles_blind = value
end)

-- -- Delete
menu.toggle(world_all_vehicles_root, "Delete", {"ryanalldelete"}, "Deletes their vehicle.", function(value)
    all_vehicles_delete = value
end)

function mod_vehicle(vehicle, action, take_control)
    if take_control then Ryan.Entity.RequestControlLoop(vehicle) end
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        action(vehicle)
    end
end

all_vehicles_state = {}

-- -- Apply Changes
util.create_tick_handler(function()
    local player_ped = Ryan.Player.GetPed()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped)

    local vehicles = Ryan.Entity.GetAllNearby(player_coords, 250, Ryan.Entity.Type.Vehicles)
    for _, vehicle in pairs(vehicles) do
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        local is_a_player = PED.IS_PED_A_PLAYER(driver)

        if all_vehicles_include_own or vehicle ~= entities.get_user_vehicle_as_handle() then
            if (all_vehicles_include_players and is_a_player) or (all_vehicles_include_npcs and not is_a_player) then
                if all_vehicles_state[vehicle] == nil then all_vehicles_state[vehicle] = {} end
                if not is_a_player then Ryan.Entity.RequestControl(vehicle) end

                -- Speed
                if all_vehicles_speed == "fast" and (not is_a_player or all_vehicles_state[vehicle].speed ~= "fast") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Fast)
                        if is_a_player then all_vehicles_state[vehicle].speed = "fast" end
                    end, is_a_player)
                elseif all_vehicles_speed == "slow" and (not is_a_player or all_vehicles_state[vehicle].speed ~= "slow") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Slow)
                        if is_a_player then all_vehicles_state[vehicle].speed = "slow" end
                    end, is_a_player)
                elseif all_vehicles_speed == "normal" and (not is_a_player or all_vehicles_state[vehicle].speed ~= "normal") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Normal)
                        if is_a_player then all_vehicles_state[vehicle].speed = "normal" end
                    end, is_a_player)
                end

                -- Grip
                if all_vehicles_grip == "none" and (not is_a_player or all_vehicles_state[vehicle].grip ~= "none") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetNoGrip(vehicle, true)
                        if is_a_player then all_vehicles_state[vehicle].grip = "off" end
                    end, is_a_player)
                elseif all_vehicles_grip == "full" and (not is_a_player or all_vehicles_state[vehicle].grip ~= "full") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetNoGrip(vehicle, false)
                        if is_a_player then all_vehicles_state[vehicle].grip = "full" end
                    end, is_a_player)
                end

                -- Doors
                if all_vehicles_doors == "lock" and (not is_a_player or all_vehicles_state[vehicle].doors ~= "lock") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetDoorsLocked(vehicle, true)
                        if is_a_player then all_vehicles_state[vehicle].doors = "lock" end
                    end, is_a_player)
                elseif all_vehicles_doors == "unlock" and (not is_a_player or all_vehicles_state[vehicle].doors ~= "unlock") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetDoorsLocked(vehicle, false)
                        if is_a_player then all_vehicles_state[vehicle].doors = "unlock" end
                    end, is_a_player)
                end

                -- Tires
                if all_vehicles_tires == "burst" and (not is_a_player or all_vehicles_state[vehicle].tires ~= "burst") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetTiresBursted(vehicle, true)
                        if is_a_player then all_vehicles_state[vehicle].tires = "burst" end
                    end, is_a_player)
                elseif all_vehicles_tires == "fix" and (not is_a_player or all_vehicles_state[vehicle].tires ~= "fix") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetTiresBursted(vehicle, false)
                        if is_a_player then all_vehicles_state[vehicle].tires = "fix" end
                    end, is_a_player)
                end

                -- Engine
                if all_vehicles_engine == "kill" and (not is_a_player or all_vehicles_state[vehicle].engine ~= "kill") then
                    mod_vehicle(vehicle, function()
                        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                        if is_a_player then all_vehicles_state[vehicle].engine = "kill" end
                    end, is_a_player)
                elseif all_vehicles_engine == "fix" and (not is_a_player or all_vehicles_state[vehicle].engine ~= "fix") then
                    mod_vehicle(vehicle, function()
                        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                        if is_a_player then all_vehicles_state[vehicle].engine = "fix" end
                    end, is_a_player)
                end

                -- Upgrades
                if all_vehicles_upgrades == "all" and (not is_a_player or all_vehicles_state[vehicle].upgrades ~= "all") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetFullyUpgraded(vehicle, true)
                        if is_a_player then all_vehicles_state[vehicle].upgrades = "all" end
                    end, is_a_player)
                elseif all_vehicles_upgrades == "none" and (not is_a_player or all_vehicles_state[vehicle].upgrades ~= "none") then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.SetFullyUpgraded(vehicle, false)
                        if is_a_player then all_vehicles_state[vehicle].upgrades = "none" end
                    end, is_a_player)
                end

                -- Catapult
                if all_vehicles_catapult then
                    if VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) then
                        mod_vehicle(vehicle, function()
                            Ryan.Vehicle.Catapult(vehicle)
                        end, is_a_player)
                    end
                end

                -- Alarm
                if all_vehicles_alarm then
                    if not VEHICLE.IS_VEHICLE_ALARM_ACTIVATED(vehicle) then
                        mod_vehicle(vehicle, function()
                            VEHICLE.SET_VEHICLE_ALARM(vehicle, true)
                            VEHICLE.START_VEHICLE_ALARM(vehicle)
                        end, is_a_player)
                    end
                end

                -- Flee
                if all_vehicles_flee and not is_a_player and all_vehicles_state[vehicle].flee ~= true then
                    TASK.TASK_SMART_FLEE_PED(driver, Ryan.Player.GetPed(), 500.0, -1, false, false)
                    all_vehicles_state[vehicle].flee = true
                end

                -- Blind
                if all_vehicles_blind and not is_a_player and (all_vehicles_state[vehicle].blind ~= true or math.random(1, 10) >= 8) then
                    PED.SET_DRIVER_AGGRESSIVENESS(driver, 1.0)
                    local coords = Ryan.Vector.Add(ENTITY.GET_ENTITY_COORDS(vehicle), {x = math.random(-500, 500), y = math.random(-500, 500), z = 0})
                    --TASK.TASK_VEHICLE_DRIVE_WANDER(driver, vehicle, 10.0, 4719104)
                    --MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, coords.z, ground_z, false)
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(driver, vehicle, coords.x, coords.y, coords.z, 150.0, 524800, 20.0)
                    --memory.free(ground_z)

                    all_vehicles_state[vehicle].blind = true
                end

                -- Delete
                if all_vehicles_delete then
                    entities.delete_by_handle(vehicle)
                end
            end
        end
    end

    util.yield(500)
end)


-- Session Menu --
menu.divider(session_root, "General")
session_trolling_root = menu.list(session_root, "Trolling...", {"ryantrolling"}, "Trolling options on all players.")
session_nuke_root = menu.list(session_root, "Nuke...", {"ryannuke"}, "Plays a siren, timer, and bomb with additional earrape.")
session_dox_root = menu.list(session_root, "Dox...", {"ryandox"}, "Shares information players probably want private.")
session_crash_all_root = menu.list(session_root, "Crash All...", {"ryancrashall"}, "The ultimate session crash.")
session_antihermit_root = menu.list(session_root, "Anti-Hermit...", {"ryanantihermit"}, "Kicks or trolls any player who stays inside for more than 5 minutes.")

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
    Ryan.Session.WatchMassCommands({"enemyclone{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Chop", {"ryanattackallchop"}, "Sends Chop to attack all players.", function()
    util.toast("Sending Chop after all players...")
    Ryan.Session.WatchMassCommands({"sendchop{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Police", {"ryanattackallpolice"}, "Sends the law to attack all players.", function()
    util.toast("Sending a police car after all players...")
    Ryan.Session.WatchMassCommands({"sendpolicecar{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Military Squad", {"ryanattackallmilitary"}, "Sends a military squad to attack all players..", function()
    util.toast("Sending a military squad after all players...")
    Ryan.Session.WatchMassAction(function(player_id)
        Ryan.Trolling.MilitarySquad(player_id, false)
    end, trolling_include_modders, trolling_watch_time)
end)

menu.divider(session_trolling_root, "Vehicle")
menu.action(session_trolling_root, "Tow", {"ryantowall"}, "Sends a tow truck to all players.", function()
    util.toast("Towing all players...")
    Ryan.Session.WatchMassCommands({"towtruck{name}"}, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Burst Tires", {"ryanbursttiresall"}, "Bursts everyone's tires.", function()
    util.toast("Bursting all tires...")
    Ryan.Session.WatchMassVehicleTakeover(function(vehicle)
        Ryan.Vehicle.SetTiresBursted(vehicle, true)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Kill Engine", {"ryankillengineall"}, "Kills everyone's engine.", function()
    util.toast("Killing all engines...")
    Ryan.Session.WatchMassVehicleTakeover(function(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
    end, trolling_include_modders, trolling_watch_time)
end)
menu.action(session_trolling_root, "Catapult", {"ryancatapultall"}, "Catapults everyone's vehicles.", function()
    util.toast("Catapulting all players...")
    Ryan.Session.WatchMassVehicleTakeover(function(vehicle)
        Ryan.Vehicle.Catapult(vehicle)
    end, trolling_include_modders, trolling_watch_time)
end)

menu.divider(session_trolling_root, "Cancel")
menu.action(session_trolling_root, "Stop Trolling", {"ryanstoptrolling"}, "Stops the session trolling, if one is in progress.", function()
    Ryan.Session.CancelMassTrolling()
end)


-- -- Nuke
nuke_spam_enabled = false
nuke_spam_message = "Get Ryan's Menu for Stand!"

menu.action(session_nuke_root, "Start Nuke", {"ryannukestart"}, "Starts the nuke.", function()
    util.toast("Nuke incoming.")
    Ryan.Audio.PlayOnAllPlayers("DLC_sum20_Business_Battle_AC_Sounds", "Air_Defences_Activated"); util.yield(3000)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(1000)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(1000)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(500)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(500)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Audio.PlayOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.Session.ExplodeAll(true)
    if nuke_spam_enabled then
        Ryan.Session.SpamChat(nuke_spam_message, true, 100, 0)
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
menu.divider(session_dox_root, "Highest & Lowest")
menu.action(session_dox_root, "Money", {"ryanrichest"}, "Shares the name of the richest and poorest players.", function()
    Ryan.Session.ListByMoney()
end)
menu.action(session_dox_root, "K/D Ratio", {"ryankd"}, "Shares the name of the highest and lowest K/D players.", function()
    Ryan.Session.ListByKD()
end)

menu.divider(session_dox_root, "List All")
menu.action(session_dox_root, "Godmode", {"ryangodmode"}, "Shares the name of the players in godmode.", function()
    Ryan.Session.ListByInGodmode()
end)
menu.action(session_dox_root, "Off Radar", {"ryanoffradar"}, "Shares the name of the players off the radar.", function()
    Ryan.Session.ListByOffRadar()
end)
menu.action(session_dox_root, "Oppressor", {"ryanoppressor"}, "Shares the name of the players in Oppressors.", function()
    Ryan.Session.ListByOnOppressor2()
end)

-- -- Crash All
crash_all_friends = false
crash_all_modders = false

menu.action(session_crash_all_root, "Crash To Singleplayer", {"ryancrashallsingleplayer"}, "Attempts to crash using all to singleplayer.", function()
    for _, player_id in pairs(players.list(false, crash_all_friends)) do
        if crash_all_modders or not players.is_marked_as_modder(player_id) then
            util.create_thread(function()
                Ryan.Player.CrashToSingleplayer(player_id)
            end)
        end
    end
end)
menu.action(session_crash_all_root, "Crash To Desktop", {"ryancrashallmultiplayer"}, "Attempts to crash using all known entities.", function()
    local starting_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
    local in_danger_zone = false
    for _, player_id in pairs(players.list(false, crash_all_friends)) do
        if Ryan.Vector.Distance(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id)), starting_coords) < Ryan.Globals.SafeCrashDistance then
            in_danger_zone = true
        end
    end

    if in_danger_zone then
        Ryan.Player.Teleport(Ryan.Globals.SafeCrashCoords)
        util.yield(1000)
    end
    for _, player_id in pairs(players.list(false, crash_all_friends)) do
        if crash_all_modders or not players.is_marked_as_modder(player_id) then
            util.create_thread(function()
                Ryan.Player.CrashToDesktop(player_id, "Yo Momma", false)
            end)
        end
    end
    if in_danger_zone then
        util.yield(Ryan.Globals.SafeCrashDuration)
        Ryan.Player.Teleport(starting_coords)
    end
end)
menu.action(session_crash_all_root, "Crash Using Stand", {"ryannextgen"}, "Attempts to crash using Stand's Next-Gen crashmocf.", function()
    for _, player_id in pairs(players.list(false, crash_all_friends)) do
        if crash_all_modders or not players.is_marked_as_modder(player_id) then
            menu.trigger_commands("ngcrash" .. players.get_name(player_id))
        end
    end
end)

menu.divider(session_crash_all_root, "Options")
menu.toggle(session_crash_all_root, "Include Modders", {"ryanomnicrashmodders"}, "If enabled, modders are included in the Omnicrash.", function(value)
    crash_all_modders = value
end)
menu.toggle(session_crash_all_root, "Include Friends", {"ryanomnicrashfriends"}, "If enabled, friends are included in the Omnicrash.", function(value)
    crash_all_friends = value
end)

-- -- Anti-Hermit
antihermit_mode = "Off"
antihermit_change = 2147483647
antihermit_values = {["Off"] = true}

for _, mode in pairs(Ryan.Globals.AntihermitModes) do
    menu.toggle(session_antihermit_root, mode, {"ryanantihermit" .. Ryan.Basics.StringToCommandName(mode)}, "", function(value)
        if value then
            if mode ~= antihermit_mode then
                menu.trigger_commands("ryanantihermit" .. Ryan.Basics.StringToCommandName(antihermit_mode) .. " off")
                antihermit_mode = mode
            end
        end

        antihermit_change = util.current_time_millis()
        antihermit_values[mode] = value
    end, mode == "Off")
end

util.create_tick_handler(function()
    if util.current_time_millis() - antihermit_change > 500 then
        local has_choice = false
        for _, mode in pairs(Ryan.Globals.AntihermitModes) do
            if antihermit_values[mode] then has_choice = true end
        end
        if not has_choice then menu.trigger_commands("ryanantihermitoff on") end
        antihermit_change = 2147483647
    end
end)

hermits = {}
hermit_list = {}
util.create_tick_handler(function()
    if not is_switching_sessions() then
        for _, player_id in pairs(players.list(false)) do
            if not players.is_marked_as_modder(player_id) then
                local tracked = false
                local player_name = players.get_name(player_id)
                if players.is_in_interior(player_id) then
                    if hermits[player_id] == nil then
                        hermits[player_id] = util.current_time_millis()
                        if antihermit_mode ~= "Off" then
                            util.toast(player_name .. " is now inside a building.")
                        end
                    elseif hermit_list[player_id] ~= nil then
                        hermits[player_id] = util.current_time_millis() - 210000
                        hermit_list[player_id] = nil
                    elseif util.current_time_millis() - hermits[player_id] >= 300000 then
                        hermits[player_id] = util.current_time_millis() - 210000
                        hermit_list[player_id] = true
                        if antihermit_mode ~= "Off" then
                            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Anti-Hermit", player_name .. " has been inside for 5 minutes. Now doing: " .. antihermit_mode .. "!")
                            Ryan.Player.SpamTexts(player_id, "You've been inside too long. Stop being weird and play the game!", 1500)
                            if antihermit_mode == "Teleport Outside" then
                                menu.trigger_commands("apt1" .. player_name)
                            elseif antihermit_mode == "Kick" then
                                menu.trigger_commands("kick" .. player_name)
                            elseif antihermit_mode == "Crash" then
                                menu.trigger_commands("ngcrash" .. player_name)
                            end
                        end
                    end
                else
                    if hermits[player_id] ~= nil then 
                        local time = Ryan.Basics.FormatTimespan(util.current_time_millis() - hermits[player_id])
                        if time ~= "" then
                            if antihermit_mode ~= "Off" then
                                util.toast(player_name .. " is no longer inside a building after " .. time .. ".")
                            end
                            hermits[player_id] = nil
                        end
                    end
                end
            end
        end
    else
        hermits = {}
        hermit_list = {}
    end
    util.yield(500)
end)

-- -- Max Players
session_max_players_root = menu.list(session_root, "Max Players...", {"ryanmax"}, "Kicks players when above a certain limit.")

max_players_amount = 0

max_players_prefer_kd = true
max_players_prefer_modders = false

max_players_include_modders = false
max_players_include_friends = false

menu.slider(session_max_players_root, "Amount", {"ryanmaxamount"}, "The maximum amount of players to allow in the session.", 0, 32, 0, 1, function(value)
    max_players_amount = value
end)

menu.divider(session_max_players_root, "Prefer Kicking")
menu.toggle(session_max_players_root, "Modders", {"ryanmaxprefermodders"}, "Kicks players detected as modders first.", function(value)
    if value then
        menu.trigger_commands("ryanmaxpreferkd off")
        if not max_players_include_modders then menu.trigger_commands("ryanmaxincludemodders on") end
    end
    max_players_modders = value
end)
menu.toggle(session_max_players_root, "High K/D", {"ryanmaxpreferkd"}, "Kicks players with the highest K/D first.", function(value)
    if value then
        menu.trigger_commands("ryanmaxprefermodders off")
    end
    max_players_prefer_kd = value
end, true)

menu.divider(session_max_players_root, "Options")
menu.toggle(session_max_players_root, "Include Modders", {"ryanmaxincludemodders"}, "If enabled, modders will be kicked.", function(value)
    if not value then menu.trigger_commands("ryanmaxprefermodders off") end
    max_players_include_modders = value
end)
menu.toggle(session_max_players_root, "Include Friends", {"ryanmaxincludefriends"}, "If enabled, friends will be kicked.", function(value)
    max_players_include_modders = value
end)

util.create_tick_handler(function()
    if max_players_amount ~= 0 then
        local player_list = players.list()
        if #player_list > max_players_amount then
            if max_players_prefer_kd or max_players_prefer_modders then
                table.sort(player_list, function(player_1, player_2)
                    if max_players_prefer_kd then
                        return players.get_kd(player_1) > players.get_kd(player_2)
                    elseif max_players_prefer_modders then
                        return (players.get_tags_string(player_1):find("M") and 1 or 0) > (players.get_tags_string(player_2):find("M") and 1 or 0)
                    end
                end)
            end

            local kick_count = #player_list - max_players_amount
            local kicked = 0
            for i = 1, #player_list do
                local can_kick = (max_players_include_modders or not players.get_tags_string(player_list[i]):find("M"))
                             and (max_players_include_friends or not players.get_tags_string(player_list[i]):find("F"))
                if player_list[i] ~= players.user() and can_kick and kicked < kick_count then
                    local reason = max_players_prefer_kd and ("having a " .. string.format("%.1f", players.get_kd(player_list[i])) .. " K/D") or ("being a modder")
                    Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Max Players", "Kicking " .. players.get_name(player_list[i]) .. " for " .. reason .. ".")
                    menu.trigger_commands("kick" .. players.get_name(player_list[i]))
                    kicked = kicked + 1
                end
            end
        end
    end
    util.yield(1000)
end)

-- -- Mk II Chaos
mk2_chaos = false
menu.toggle(session_root, "Mk II Chaos", {"ryanmk2chaos"}, "Gives everyone a Mk 2 and tells them to duel.", function(value)
    mk2_chaos = value    
end)

util.create_tick_handler(function()
    if mk2_chaos then
        chat.send_message("This session is in Mk II Chaos mode! Every 3 minutes, everyone receives an Oppressor. Good luck.", false, true, true)
        local oppressor2 = util.joaat("oppressor2")
        Ryan.Basics.RequestModel(oppressor2)
        for _, player_id in pairs(players.list()) do
            local player_ped = Ryan.Player.GetPed(player_id)
            local coords = Ryan.Vector.Add(ENTITY.GET_ENTITY_COORDS(player_ped), {x = 0.0, y = 5.0, z = 0.0})
            local vehicle = entities.create_vehicle(oppressor2, coords, ENTITY.GET_ENTITY_HEADING(player_ped))
            Ryan.Entity.RequestControlLoop(vehicle)
            Ryan.Vehicle.SetFullyUpgraded(vehicle, true)
            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, true)
            VEHICLE.SET_VEHICLE_DOOR_LATCHED(vehicle, 0, false, false, true)
        end
        Ryan.Basics.FreeModel(oppressor2)
        util.yield(180000)
    end
end)

-- Vehicle
menu.divider(session_root, "Vehicle")
session_drivers_root = menu.list(session_root, "Driver List...", {"ryandrivers"}, "Lists the players driving vehicles.")

-- -- Drivers
drivers = {}
drivers_refresh = 0
drivers_refresh_text = nil

util.create_thread(function()
    while true do
        if util.current_time_millis() - drivers_refresh >= 10000 then
            if drivers_refresh_text ~= nil then menu.delete(drivers_refresh_text) end
            for _, driver in pairs(drivers) do menu.delete(driver) end
            drivers = {}
            for _, player_id in pairs(players.list()) do
                local vehicle = players.get_vehicle_model(player_id)
                if vehicle ~= 0 then
                    table.insert(drivers, menu.action(session_drivers_root, players.get_name(player_id), {"ryandriver" .. players.get_name(player_id)}, "", function()
                        menu.trigger_commands("p " .. players.get_name(player_id))
                    end))
                end
            end
            drivers_refresh_text = menu.divider(session_drivers_root, "")
            drivers_refresh = util.current_time_millis()
        elseif drivers_refresh_text ~= nil then
            menu.set_menu_name(drivers_refresh_text, "Refreshing In: " .. math.floor(11 - (util.current_time_millis() - drivers_refresh) / 1000))
        end
        util.yield()
    end
end)

-- Teleport All
session_vehicle_trolling_root = menu.list(session_root, "Trolling...", {"ryantpvehicles"}, "Forces every vehicle into an area.")
    
menu.toggle_loop(session_vehicle_trolling_root, "Teleport To Me", {"ryantpme"}, "Teleports them to your location.", function()
    local coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed())
    for _, player_id in pairs(players.list()) do
        if Ryan.Vector.Distance(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id)), coords) > 33.33 then
            Ryan.Player.TeleportVehicle(player_id, Ryan.Vector.Add(coords, {x = math.random(-10, 10), y = math.random(-10, 10), z = 0}))
        end
    end
    util.yield(2500)
end)

menu.toggle_loop(session_vehicle_trolling_root, "Delete", {"ryandelete"}, "Deletes their vehicles.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(player_id), true)
        if vehicle ~= 0 then
            entities.delete_by_handle(vehicle)
        end
    end
    util.yield(500)
end)


-- Stats Menu --
menu.divider(stats_root, "Player")
stats_kd_root = menu.list(stats_root, "Kills/Deaths...", {"ryankd"}, "Controls your kills and deaths.")
menu.action(stats_root, "Favorite Radio Station", {"ryanradio"}, "Sets your favorite station to the one currently playing.", function()
    Ryan.Stats.SetFavoriteRadioStation()
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
            Ryan.Stats.SetKills(math.floor(value))
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Stats", "Your kill count has been changed to " .. value .. "!")
        else
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Stats", "The kill count you provided was not a valid number.")
        end
        create_kd_inputs()
    end)

    stats_deaths = menu.text_input(stats_kd_root, "Deaths: -", {"ryandeaths"}, "The amount of deaths you have received.", function(value)
        value = tonumber(value)
        if value ~= nil then
            Ryan.Stats.SetDeaths(math.floor(value))
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Stats", "Your death count has been changed to " .. value .. "!")
        else
            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Stats", "The death count you provided was not a valid number.")
        end
        create_kd_inputs()
    end)

    stats_kd = menu.divider(stats_kd_root, "K/D: -")
end

create_kd_inputs()

-- -- CEO Office Money
office_money_0 = menu.action(stats_office_money_root, "0% Full", {"ryanofficemoney0"}, "Makes the office 0% full with money.", function(click_type)
    Ryan.Stats.SetOfficeMoney(office_money_0, click_type, 0)
end)
office_money_25 = menu.action(stats_office_money_root, "25% Full", {"ryanofficemoney25"}, "Makes the office 25% full with money.", function(click_type)
    Ryan.Stats.SetOfficeMoney(office_money_25, click_type, 5000000)
end)
office_money_50 = menu.action(stats_office_money_root, "50% Full", {"ryanofficemoney50"}, "Makes the office 50% full with money.", function(click_type)
    Ryan.Stats.SetOfficeMoney(office_money_50, click_type, 10000000)
end)
office_money_75 = menu.action(stats_office_money_root, "75% Full", {"ryanofficemoney75"}, "Makes the office 75% full with money.", function(click_type)
    Ryan.Stats.SetOfficeMoney(office_money_75, click_type, 15000000)
end)
office_money_100 = menu.action(stats_office_money_root, "100% Full", {"ryanofficemoney100"}, "Makes the office 100% full with money.", function(click_type)
    Ryan.Stats.SetOfficeMoney(office_money_100, click_type, 20000000)
end)

-- -- MC Clubhouse Clutter
mc_clutter_0 = menu.action(stats_mc_clutter_root, "0% Full", {"ryanmcclutter0"}, "Removes drugs, money, and other clutter to your M.C. clubhouse.", function(click_type)
    Ryan.Stats.SetMCClutter(mc_clutter_0, click_type, 0)
end)
mc_clutter_100 = menu.action(stats_mc_clutter_root, "100% Full", {"ryanmcclutter100"}, "Adds drugs, money, and other clutter to your M.C. clubhouse.", function(click_type)
    Ryan.Stats.SetMCClutter(mc_clutter_100, click_type, 20000000)
end)

util.create_tick_handler(function()
    if stats_kills ~= nil and stats_deaths ~= nil then
        local kills, deaths = Ryan.Stats.GetKills(), Ryan.Stats.GetDeaths()
        menu.set_menu_name(stats_kills, "Kills: " .. kills)
        menu.set_menu_name(stats_deaths, "Deaths: " .. deaths)
        menu.set_menu_name(stats_kd, "K/D: " .. string.format("%.2f", kills / deaths))
        util.yield(10000)
    end
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
    Ryan.Basics.TranslateTo(chat_prefix .. chat_message, "ES", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Russian", {"ryantranslaterussian"}, "Translate to Russian.", function()
    util.toast("Translating message to Russian...")
    Ryan.Basics.TranslateTo(chat_prefix .. chat_message, "RU", true)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Russian (Cyrillic)", {"ryantranslatecyrillic"}, "Translate to Russian (Cyrillic).", function()
    util.toast("Translating message to Russian (Cyrillic)...")
    Ryan.Basics.TranslateTo(chat_prefix .. chat_message, "RU", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "French", {"ryantranslatefrench"}, "Translate to French.", function()
    util.toast("Translating message to French...")
    Ryan.Basics.TranslateTo(chat_prefix .. chat_message, "FR", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "German", {"ryantranslategerman"}, "Translate to German.", function()
    util.toast("Translating message to German...")
    Ryan.Basics.TranslateTo(chat_prefix .. chat_message, "DE", false)
    menu.focus(chat_send_root)
end)
menu.action(chat_send_root, "Italian", {"ryantranslateitalian"}, "Translate to Italian.", function()
    util.toast("Translating message to Italian...")
    Ryan.Basics.TranslateTo(chat_prefix .. chat_message, "IT", false)
    menu.focus(chat_send_root)
end)


menu.divider(chat_root, "Chat Options")

-- -- Commands
enable_commands = false
menu.toggle(chat_root, "Enable Commands", {"ryancommands"}, "Enables commands for all players. Use !help for a list.", function(value)
    enable_commands = value
end)

-- -- Crashes Money Beggars
crash_money_beggars = false
menu.toggle(chat_root, "Crash Money Beggars", {"ryancrashbeggars"}, "Crashes anyone who begs for money.", function(value)
    crash_money_beggars = value
end)

-- -- Crashes Car Meeters
crash_car_meeters = false
menu.toggle(chat_root, "Crash Car Meeters", {"ryancrashcarmeets"}, "Crashes anyone who suggests a car meet.", function(value)
    crash_car_meeters = value
end)

function reply(message)
    chat.send_message("∑ " .. message .. " ∑", false, true, true)
end

chat_history = {}
chat_index = 1

chat_commands = {
    {"help", {}, "Lists the available commands and their usage.", nil},
    {"nuke", {}, "Drops a nuke on the session.", "ryannukestart"},
    {"crash", {"player"}, "Crashes a player to their desktop.", "ryandesktop{1}"},
    {"tank", {"player"}, "Drops a tank on a player's head.", "ryanfallingtank{1}"},
    {"cage", {"player"}, "Cages a player, over and over again.", "autocage{1} on"},
    {"carslow", {"player"}, "Makes a player's car slow.", "ryanspeedslow{1} on"},
    {"carlock", {"player"}, "Locks a player in their car.", "ryandoorslock{1} on"},
    {"cardelete", {"player"}, "Deletes the player's car.", "ryandelete{1} on"}
}

chat.on_message(function(packet_sender, sender, message, is_team_chat)
    local message_lower = message:lower()
    if crash_money_beggars then
        if (message_lower:find("can") or message_lower:find("?") or message_lower:find("please") or message_lower:find("plz") or message_lower:find("pls") or message_lower:find("drop"))
        and message_lower:find("money") then

            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Crash Money Beggars", players.get_name(sender) .. " is being crashed for begging for money drops.")
            menu.trigger_commands("ngcrash" .. players.get_name(sender))
        end
    end
    if crash_car_meeters then
        if (message_lower:find("want to") or message_lower:find("wanna") or message_lower:find("at") or message_lower:find("is") or message_lower:find("?"))
        and message_lower:find("car") and message_lower:find("meet") then

            Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Crash Car Meeters", players.get_name(sender) .. " is being crashed for suggesting a car meet.")
            menu.trigger_commands("ngcrash" .. players.get_name(sender))
        end
    end

    if enable_commands and message_lower:sub(1, 1) == "!" then
        local command_found = false
        for _, command in pairs(chat_commands) do
            if message_lower:sub(1, command[1]:len() + 1) == "!" .. command[1] then
                command_found = true

                -- Split Arguments
                local args = {}
                local required_args = ""
                for arg in message:sub(command[1]:len() + 2):gmatch("%S+") do table.insert(args, arg) end
                for _, arg in pairs(command[2]) do required_args = required_args .. " [" .. arg .. "]" end
                if #args < #command[2] then
                    reply("Usage: !" .. command[1] .. required_args)
                else
                    -- Parse Arguments
                    local has_error = false
                    for i, arg_type in pairs(command[2]) do
                        if arg_type == "player" then
                            local player_found = false
                            for _, player_id in pairs(players.list()) do
                                if players.get_name(player_id):lower():find(args[i]:lower()) == 1 then
                                    args[i] = player_id
                                    player_found = true
                                end
                            end
                            if not player_found then
                                reply("Player '" .. args[i] .. "' could not be found.")
                                has_error = true
                            end
                        end
                    end

                    -- Handle Command
                    if not has_error then
                        if command[4] ~= nil then
                            local raw_command = command[4]
                            for i, arg_type in pairs(command[2]) do
                                if arg_type == "player" then raw_command = raw_command:gsub("{" .. i .. "}", players.get_name(args[i])) end
                            end
                            menu.trigger_commands(raw_command)
                            reply("Successfully executed command!")
                        elseif command[1] == "help" then
                            local cmd_list = ""
                            for i, cmd in pairs(chat_commands) do
                                if i ~= 1 then
                                    local cmd_args = ""
                                    local cmd_exact = #args > 0 and cmd[1] == args[1]
                                    for _, arg in pairs(cmd[2]) do cmd_args = cmd_args .. " [" .. arg .. "]" end
                                    if #args == 0 or cmd_exact then
                                        cmd_list = cmd_list .. "!" .. cmd[1] .. cmd_args .. (cmd_exact and ": " .. cmd[3] or "") .. ", "
                                    end
                                end 
                            end
                            if cmd_list:len() > 0 then reply(cmd_list:sub(1, cmd_list:len() - 2))
                            else reply("Unknown command. Use !help for a list of them.") end
                        end
                    end
                end
            end
        end
        if not command_found then reply("Unknown command. Use !help for a list of them.") end
    end

    if #chat_history > 30 then
        menu.delete(chat_history[1])
        table.remove(chat_history, 1)
    end
    table.insert(
        chat_history,
        menu.action(chat_history_root, "\"" .. message .. "\"", {"ryanchathistory" .. chat_index}, "Translate this message into English.", function()
            Ryan.Basics.TranslateFrom(message)
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
menu.colour(settings_root, "ESP Color", {"ryanespcolor"}, "The color of on-screen ESP.", 0.29, 0.69, 1.0, 1.0, false, function(value)
    esp_color.r = value.r
    esp_color.g = value.g
    esp_color.b = value.b
end)
menu.action(settings_root, "Allow Fireworks", {"ryanallowfireworks"}, "Disable Crash Event - Timeout to allow for fireworks.", function()
    menu.focus(menu.ref_by_path("Online>Protections>Events>Crash Event>Timeout"))
end)

-- Player Options --
ptfx_attack = {}
money_drop = {}
remove_godmode = {}
remove_godmode_notice = {}
entities_message = {}

vehicle_state = {}

vehicle_speed = {}
vehicle_grip = {}
vehicle_doors = {}
vehicle_tires = {}
vehicle_engine = {}
vehicle_upgrades = {}
vehicle_godmode = {}

vehicle_catapult = {}
vehicle_alarm = {}
vehicle_spotlight = {}
vehicle_delete = {}

attach_vehicle_bones = {}
attach_vehicle_vehicle = {}
attach_vehicle_notice = {}
attach_vehicle_offset = {}
attach_vehicle_root = {}

function spam_then(player_id, action)
    local do_spam = entities_message[player_id] ~= nil and entities_message[player_id] ~= "" and entities_message[player_id] ~= " "
    if do_spam then
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Entity Trolling", "Spamming " .. players.get_name(player_id) .. " and then spawning entities on them...")
        Ryan.Player.SpamTexts(player_id, entities_message[player_id], 1250)
    else
        Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Entity Trolling", "Spawning entities on " .. players.get_name(player_id) .. "!")
    end
    action()
end

function setup_player(player_id)
    local player_root = menu.player_root(player_id)
    menu.divider(player_root, "Ryan's Menu")

    local player_name = players.get_name(player_id)
    local player_trolling_root = menu.list(player_root, "Trolling...", {"ryantrolling"}, "Options that players may not like.")
    local player_removal_root = menu.list(player_root, "Removal...", {"ryanremoval"}, "Options to remove the player forcibly.")


    -- Trolling --
    local player_vehicle_root = menu.list(player_trolling_root, "Vehicle...", {"ryanvehicle"}, "Vehicle trolling options.")

    -- -- Speed
    local player_vehicle_speed_root = menu.list(player_vehicle_root, "Speed: -", {"ryanspeed"}, "Changes the speed of their vehicle.")
    menu.toggle(player_vehicle_speed_root, "Fast", {"ryanspeedfast"}, "Makes the speed extremely fast.", function(value)
        if value then
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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
    local player_vehicle_upgrades_root = menu.list(player_vehicle_root, "Upgrades: -", {"ryanupgrades"}, "Changes their vehicle's upgrades.")
    menu.toggle(player_vehicle_upgrades_root, "All", {"ryanupgradesall"}, "Fully upgrades the vehicle.", function(value)
        if value then
            Ryan.Basics.RunCommands({
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
            Ryan.Basics.RunCommands({
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

    -- -- Godmode
    local player_vehicle_godmode_root = menu.list(player_vehicle_root, "Godmode: -", {"ryangodmode"}, "Makes their vehicle indestructible.")
    menu.toggle(player_vehicle_godmode_root, "On", {"ryangodmodeon"}, "Enables godmode.", function(value)
        if value then
            Ryan.Basics.RunCommands({
                "ryangodmodeoff" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_godmode[player_id] = "on"
            menu.set_menu_name(player_vehicle_godmode_root, "Godmode: On")
        else
            vehicle_godmode[player_id] = nil
            menu.set_menu_name(player_vehicle_godmode_root, "Godmode: -")
        end
    end)
    menu.toggle(player_vehicle_godmode_root, "Off", {"ryangodmodeoff"}, "Disables godmode.", function(value)
        if value then
            Ryan.Basics.RunCommands({
                "ryangodmodeon" .. player_name .. " off"
            })
            util.yield(250)
            vehicle_godmode[player_id] = "off"
            menu.set_menu_name(player_vehicle_godmode_root, "Godmode: Off")
        else
            vehicle_godmode[player_id] = nil
            menu.set_menu_name(player_vehicle_godmode_root, "Godmode: -")
        end
    end)

    -- -- Catapult
    menu.toggle(player_vehicle_root, "Catapult", {"ryancatapult"}, "Catapults their car non-stop.", function(value)
        vehicle_catapult[player_id] = value and true or nil
    end)

    -- -- Alarm
    menu.toggle(player_vehicle_root, "Alarm", {"ryanalarm"}, "Triggers their vehicle's theft alarm.", function(value)
        vehicle_alarm[player_id] = value and true or nil
    end)

    -- -- Spotlight
    menu.toggle(player_vehicle_root, "Spotlight", {"ryanspotlight"}, "Attaches blindingly bright lights to their vehicle.", function(value)
        vehicle_spotlight[player_id] = value and true or nil
    end)

    -- -- Delete
    menu.toggle(player_vehicle_root, "Delete", {"ryandelete"}, "Deletes their vehicle.", function(value)
        vehicle_delete[player_id] = value and true or nil
    end)


    -- Entities --
    local player_trolling_entities_root = menu.list(player_trolling_root, "Entities...", {"ryanentities"}, "Entity trolling options.")
    
    -- -- Stripper El Rubio
    menu.action(player_trolling_entities_root, "Pole-Dancing El Rubio", {"ryanelrubio"}, "Spawns an El Rubio whose fortune has been stolen, leading him to the pole.", function()
        spam_then(player_id, function() Ryan.Trolling.StripperElRubio(player_id) end)
    end)

    -- -- Transgender Go-Karts
    menu.action(player_trolling_entities_root, "Transgender Go-Karts", {"ryanmilitarykarts"}, "Spawns a military squad in go-karts.", function()
        spam_then(player_id, function() Ryan.Trolling.GoKarts(player_id, "a_m_m_tranvest_01") end)
    end)

    -- -- Military Squad
    menu.action(player_trolling_entities_root, "Military Squad", {"ryanmilitarysquad"}, "Send an entire fucking military squad.", function()
		spam_then(player_id, function() Ryan.Trolling.MilitarySquad(player_id, true) end)
    end)

    -- -- SWAT Raid
    menu.action(player_trolling_entities_root, "SWAT Raid", {"ryanswatraid"}, "Sends a SWAT team to kill them, brutally.", function()
        spam_then(player_id, function() Ryan.Trolling.SWATTeam(player_id) end)
    end)

    -- -- Trash Pickup
    menu.action(player_trolling_entities_root, "Trash Pickup", {"ryantrashpickup"}, "Send the trash man to 'clean up' the street. Yasha's idea.", function()
        spam_then(player_id, function() Ryan.Trolling.TrashPickup(player_id) end)
    end)

    -- -- Flying Yacht
    menu.action(player_trolling_entities_root, "Flying Yacht", {"ryanflyingyacht"}, "Send the magic school yacht to fuck their shit up.", function()
        spam_then(player_id, function() Ryan.Trolling.FlyingYacht(player_id) end)
    end)
    
    -- -- Falling Tank
    menu.action(player_trolling_entities_root, "Falling Tank", {"ryanfallingtank"}, "Send a tank straight from heaven.", function()
		spam_then(player_id, function() Ryan.Trolling.FallingTank(player_id) end)
    end)

    menu.divider(player_trolling_entities_root, "Options")
    menu.text_input(player_trolling_entities_root, "Spam Message", {"ryanentitiesspam"}, "The message to spam before spawning entities.", function(value)
        entities_message[player_id] = value
    end, entities_message[player_id] or "")
    menu.action(player_trolling_entities_root, "Delete All", {"ryanentitiesdelete"}, "Deletes all previously spawned entities.", function()
        Ryan.Trolling.DeleteEntities(player_id)
    end)


    -- -- Attach
    attach_vehicle_root[player_id] = menu.list(player_trolling_root, "Attach...", {"ryanattach"}, "Attaches to their vehicle on a specific bone.")
    attach_vehicle_offset[player_id] = 0.0
    attach_vehicle_notice[player_id] = nil
    attach_vehicle_bones[player_id] = {}

    menu.action(attach_vehicle_root[player_id], "Detach", {"ryandetach"}, "Detaches from anything you're attached to.", function()
        util.toast("Detaching...")
        ENTITY.DETACH_ENTITY(Ryan.Player.GetPed(), false, false)
    end)
    menu.slider(attach_vehicle_root[player_id], "Offset", {"ryanattachoffset"}, "Offset of the Z coordinate.", -25, 25, 1, 0, function(value)
        attach_vehicle_offset[player_id] = value
    end)
    menu.divider(attach_vehicle_root[player_id], "Attach To")


    -- -- PTFX Attack
    menu.toggle(player_trolling_root, "PTFX Attack", {"ryanptfxattack"}, "Tries to lag the player with PTFX.", function(value)
        ptfx_attack[player_id] = value and true or nil
    end)

    -- -- Fake Money Drop
    menu.toggle(player_trolling_root, "Fake Money Drop", {"ryanfakemoney"}, "Drops fake money bags on the player.", function(value)
        money_drop[player_id] = value and true or nil
    end)


    -- -- Remove Godmode
    menu.toggle(player_trolling_root, "Remove Godmode", {"ryanremovegodmode"}, "Removes godmode from Kiddions users and their vehicles.", function(value)
        remove_godmode[player_id] = value and true or nil
        remove_godmode_notice[player_id] = util.current_time_millis()
    end)

    -- -- Steal Vehicle
    menu.action(player_trolling_root, "Steal Vehicle", {"ryansteal"}, "Steals the player's car.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(player_id))
        if vehicle ~= 0 then Ryan.Vehicle.Steal(vehicle)
        else Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Red, "Steal Vehicle", players.get_name(player_id) .. " is not in a vehicle.") end
    end)


    -- Removal --
    -- -- Text & Kick
    local removal_block_joins = false
    local removal_message = ""
    
    menu.text_input(player_removal_root, "Spam Message", {"ryanremovalspam"}, "The message to spam before removing the player.", function(value)
        removal_message = value
    end, removal_message)
    menu.toggle(player_removal_root, "Block Joins", {"ryanremovalblockjoins"}, "Block joins by this player.", function(value)
        removal_block_joins = value
    end)

    menu.divider(player_removal_root, "Go")
    -- -- Stand Kick
    menu.action(player_removal_root, "Stand Kick", {"ryankick"}, "Attempts to kick using Stand's Smart kick.", function()
        Ryan.Player.SpamTextsAndBlockJoins(player_id, removal_block_joins, removal_message, function()
            local player_name = players.get_name(player_id)
            menu.trigger_commands("kick" .. player_name)
        end)
    end)

    -- -- Crash To Singleplayer
    menu.action(player_removal_root, "Crash To Singleplayer", {"ryancrash"}, "Attempts to crash using all known script events.", function()
        Ryan.Player.SpamTextsAndBlockJoins(player_id, removal_block_joins, removal_message, function()
            Ryan.Player.CrashToSingleplayer(player_id)
        end)
    end)

    -- -- Crash To Desktop
    player_crash_to_desktop_root = menu.list(player_removal_root, "Crash To Desktop...", {"ryancrashes"}, "Various methods of crashing to desktop.")
    
    menu.action(player_crash_to_desktop_root, "Do All", {"ryandesktop"}, "Attempts to crash using all known entities.", function(click_type)
        Ryan.Player.SpamTextsAndBlockJoins(player_id, removal_block_joins, removal_message, function()
            Ryan.Player.CrashToDesktop(player_id, nil, true)
        end)
    end)

    menu.divider(player_crash_to_desktop_root, "Methods")
    for _, mode in pairs(Ryan.Globals.CrashToDesktopMethods) do
        menu.action(player_crash_to_desktop_root, mode, {"ryan" .. mode}, "Attempts to crash using the " .. mode .. " method.", function(click_type)
            Ryan.Player.SpamTextsAndBlockJoins(player_id, removal_block_joins, removal_message, function()
                Ryan.Player.CrashToDesktop(player_id, mode, true)
            end)
        end)
    end


    -- Divorce Kick --
    menu.action(player_root, "Divorce", {"ryandivorce"}, "Kicks the player, then blocks future joins by them.", function()
        local player_name = players.get_name(player_id)
        Ryan.Player.BlockJoins(player_name)
        menu.trigger_commands("kick" .. player_name)
        menu.trigger_commands("players")
    end)
end

util.create_tick_handler(function()
    for _, player_id in pairs(players.list()) do
        if remove_godmode[player_id] == true then
            Ryan.Player.RemoveGodmode(player_id, true)
            if util.current_time_millis() - remove_godmode_notice[player_id] >= 10000 then
                util.toast("Still removing godmode from " .. players.get_name(player_id) .. ".")
                remove_godmode_notice[player_id] = util.current_time_millis()
            end
        end

        if attach_vehicle_root[player_id] ~= nil then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(player_id), true)
            if vehicle ~= attach_vehicle_vehicle[player_id] then
                for _, bone in pairs(attach_vehicle_bones[player_id]) do menu.delete(bone) end
                attach_vehicle_bones[player_id] = {}

                for i = 1, #Ryan.Globals.VehicleAttachBones do
                    local bone = Ryan.Globals.VehicleAttachBones[i][2] ~= nil and ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, Ryan.Globals.VehicleAttachBones[i][2]) or 0

                    if bone ~= -1 then
                        table.insert(
                            attach_vehicle_bones[player_id],
                            menu.action(attach_vehicle_root[player_id], Ryan.Globals.VehicleAttachBones[i][1], {"ryanattach" .. Ryan.Globals.VehicleAttachBones[i][1]}, "Attaches to the bone.", function()
                                local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(player_id), true)
                                ENTITY.ATTACH_ENTITY_TO_ENTITY(Ryan.Player.GetPed(), vehicle, bone, 0.0, -0.2, (bone == 0 and 2.0 or 1.0) + (attach_vehicle_offset[player_id] * 0.2), 1.0, 1.0, 1, true, true, true, false, 0, true)
                            end)
                        )
                    end
                end

                if attach_vehicle_notice[player_id] ~= nil then
                    menu.delete(attach_vehicle_notice[player_id])
                    attach_vehicle_notice[player_id] = nil
                end
            elseif vehicle == 0 then
                for _, bone in pairs(attach_vehicle_bones[player_id]) do menu.delete(bone) end
                attach_vehicle_bones[player_id] = {}

                if attach_vehicle_notice[player_id] ~= nil then
                    menu.delete(attach_vehicle_notice[player_id])
                    attach_vehicle_notice[player_id] = nil
                end
                attach_vehicle_notice[player_id] = menu.divider(attach_vehicle_root[player_id], "Vehicle Needed")
            end

            attach_vehicle_vehicle[player_id] = vehicle
        end
    end
    util.yield(500)
end)

util.create_thread(function()
    while true do
        for player_id, enabled in pairs(money_drop) do
            if enabled then Ryan.Trolling.FakeMoneyDrop(player_id) end
        end
        util.yield()
    end
end) 

util.create_tick_handler(function()
    for _, player_id in pairs(ptfx_attack) do
        Ryan.PTFX.PlayAtCoords(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id)), "core", "exp_grd_petrol_pump_post", {r = 0, g = 0, b = 0})
        Ryan.PTFX.PlayAtCoords(ENTITY.GET_ENTITY_COORDS(Ryan.Player.GetPed(player_id)), "core", "exp_grd_petrol_pump", {r = 0, g = 0, b = 0})
    end
end)

util.create_tick_handler(function()
    for _, player_id in pairs(players.list()) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.GetPed(player_id), true)
        if vehicle ~= 0 then
            if vehicle_state[vehicle] == nil then vehicle_state[vehicle] = {} end
            
            -- Speed
            if vehicle_speed[player_id] == "fast" and vehicle_state[vehicle].speed ~= "fast" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Fast)
                    vehicle_state[vehicle].speed = "fast"
                end, true)
            elseif vehicle_speed[player_id] == "slow" and vehicle_state[vehicle].speed ~= "slow" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Slow)
                    vehicle_state[vehicle].speed = "slow"
                end, true)
            elseif vehicle_speed[player_id] == "normal" and vehicle_state[vehicle].speed ~= "normal" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetSpeed(vehicle, Ryan.Vehicle.Speed.Normal)
                    vehicle_state[vehicle].speed = "normal"
                end, true)
            end

            -- Grip
            if vehicle_grip[player_id] == "none" and vehicle_state[vehicle].grip ~= "none" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetNoGrip(vehicle, true)
                    vehicle_state[vehicle].grip = "none"
                end, true)
            elseif vehicle_grip[player_id] == "full" and vehicle_state[vehicle].grip ~= "full" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetNoGrip(vehicle, false)
                    vehicle_state[vehicle].grip = "full"
                end, true)
            end

            -- Doors
            if vehicle_doors[player_id] == "lock" and vehicle_state[vehicle].doors ~= "lock" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetDoorsLocked(vehicle, true)
                    vehicle_state[vehicle].doors = "lock"
                end, true)
            elseif vehicle_doors[player_id] == "unlock"  and vehicle_state[vehicle].doors ~= "unlock" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetDoorsLocked(vehicle, false)
                    vehicle_state[vehicle].doors = "unlock"
                end, true)
            end

            -- Tires
            if vehicle_tires[player_id] == "burst" and vehicle_state[vehicle].tires ~= "burst" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetTiresBursted(vehicle, true)
                    vehicle_state[vehicle].tires = "burst"
                end, true)
            elseif vehicle_tires[player_id] == "fix" and vehicle_state[vehicle].tires ~= "fix" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetTiresBursted(vehicle, false)
                    vehicle_state[vehicle].tires = "fix"
                end, true)
            end

            -- Engine
            if vehicle_engine[player_id] == "kill" and vehicle_state[vehicle].engine ~= "kill" then
                mod_vehicle(vehicle, function()
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                    vehicle_state[vehicle].engine = "kill"
                end, true)
            elseif vehicle_engine[player_id] == "fix" and vehicle_state[vehicle].engine ~= "fix" then
                mod_vehicle(vehicle, function()
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                    vehicle_speed[vehicle].engine = "fix"
                end, true)
            end

            -- Upgrades
            if vehicle_upgrades[player_id] == "all" and vehicle_state[vehicle].upgrades ~= "all" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetFullyUpgraded(vehicle, true)
                    vehicle_state[vehicle].upgrades = "all"
                end, true)
            elseif vehicle_upgrades[player_id] == "none" and vehicle_state[vehicle].upgrades ~= "none" then
                mod_vehicle(vehicle, function()
                    Ryan.Vehicle.SetFullyUpgraded(vehicle, false)
                    vehicle_state[vehicle].upgrades = "none"
                end, true)
            end

            -- Godmode
            if vehicle_godmode[player_id] == "on" and vehicle_state[vehicle].godmode ~= "on" then
                mod_vehicle(vehicle, function()
                    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, false)
                    vehicle_state[vehicle].godmode = "on"
                end, true)
            elseif vehicle_godmode[player_id] == "off" and vehicle_state[vehicle].godmode ~= "off" then
                mod_vehicle(vehicle, function()
                    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
                    vehicle_state[vehicle].godmode = "off"
                end, true)
            end

            -- Catapult
            if vehicle_catapult[player_id] == true then
                if VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) then
                    mod_vehicle(vehicle, function()
                        Ryan.Vehicle.Catapult(vehicle)
                    end, true)
                end
            end

            -- Alarm
            if vehicle_alarm[player_id] == true then
                if not VEHICLE.IS_VEHICLE_ALARM_ACTIVATED(vehicle) then
                    mod_vehicle(vehicle, function()
                        VEHICLE.SET_VEHICLE_ALARM(vehicle, true)
                        VEHICLE.START_VEHICLE_ALARM(vehicle)
                    end, true)
                end
            end

            -- Spotlight
            if vehicle_spotlight[player_id] == true then
                Ryan.Entity.AddSpotlight(vehicle, 4.0, 6)
            end

            -- Delete
            if vehicle_delete[player_id] == true then
                -- SET_AS_MISSION_VEHICLE
                entities.delete_by_handle(vehicle)
            end
        end
    end
    util.yield(250)
end)

function cleanup_player(player_id)
    money_drop[player_id] = nil
    ptfx_attack[player_id] = nil
    remove_godmode[player_id] = nil
    remove_godmode_notice[player_id] = nil
    entities_message[player_id] = nil
    
    vehicle_speed[player_id] = nil
    vehicle_grip[player_id] = nil
    vehicle_doors[player_id] = nil
    vehicle_tires[player_id] = nil
    vehicle_engine[player_id] = nil
    vehicle_upgrades[player_id] = nil
    vehicle_godmode[player_id] = nil

    vehicle_catapult[player_id] = nil
    vehicle_alarm[player_id] = nil
    vehicle_spotlight[player_id] = nil
    vehicle_delete[player_id] = nil
    
    attach_vehicle_bones[player_id] = nil
    attach_vehicle_vehicle[player_id] = nil
    attach_vehicle_notice[player_id] = nil
    attach_vehicle_offset[player_id] = nil
    attach_vehicle_root[player_id] = nil

    hermits[player_id] = nil
    hermit_list[player_id] = nil

    Ryan.Trolling.DeleteEntities(player_id)
end


-- Initialize --
players.on_join(function(player_id) setup_player(player_id) end)
players.on_leave(function(player_id) cleanup_player(player_id) end)
players.dispatch_on_join()

util.keep_running()


-- DirectX --
while true do
    player_is_pointing = memory.read_int(memory.script_global(4516656 + 930)) == 3
    if crosshair_mode == "Always" or (crosshair_mode == "When Pointing" and player_is_pointing) then
        local weapon = WEAPON.GET_SELECTED_PED_WEAPON(Ryan.Player.GetPed())
        if WEAPON.GET_WEAPONTYPE_GROUP(weapon) ~= -1212426201 then
            HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
        end
        directx.draw_texture(
            Ryan.Globals.CrosshairTexture,
            0.03, 0.03,
            0.5, 0.5,
            0.5, 0.5,
            0.0,
            {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
        )
    end
    
    util.yield()
end