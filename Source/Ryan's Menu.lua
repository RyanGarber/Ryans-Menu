VERSION = "0.10.3"
MANIFEST = {
    lib = {"Audio.lua", "Basics.lua", "Entity.lua", "Globals.lua", "JSON.lua", "Natives.lua", "Player.lua", "PTFX.lua", "Session.lua", "Stats.lua", "Trolling.lua", "UI.lua", "Vector.lua", "Vehicle.lua"},
    resources = {"Crosshair.png"}
}

DEV_ENVIRONMENT = debug.getinfo(1, "S").source:lower():find("dev")
SUBFOLDER_NAME = "Ryan's Menu" .. (if DEV_ENVIRONMENT then " (Dev)" else "")

Ryan = {}


-- Initialize --
function exists(name) return filesystem.exists(filesystem.scripts_dir() .. name) end
for required_directory, required_files in pairs(MANIFEST) do
    for _, required_file in pairs(required_files) do
        if not exists(required_directory .. "\\" .. SUBFOLDER_NAME .. "\\" .. required_file) then
            if required_file == "Basics.lua" or required_file == "JSON.lua" or required_file == "Natives.lua" then
                while not exists(required_directory .. "\\" .. SUBFOLDER_NAME .. "\\" .. required_file) do
                    util.toast("Ryan's Menu is missing a required file and must be reinstalled.")
                    util.yield(2000)
                end
            else
                VERSION = "-1"
            end
        elseif required_directory == 'lib' then
            require(required_directory .. "\\" .. SUBFOLDER_NAME .. "\\" .. required_file:sub(0, -5))
        end
    end
end

Ryan.Basics.DoUpdate(false)

Ryan.Globals.Initialize()
util.create_tick_handler(Ryan.Globals.OnTick)


-- Main Menu --
self_root = menu.list(menu.my_root(), "Self", {"ryanself"}, "Helpful options for yourself.")
world_root = menu.list(menu.my_root(), "World", {"ryanworld"}, "Helpful options for entities in the world.")
session_root = menu.list(menu.my_root(), "Session", {"ryansession"}, "Trolling options for the entire session.")
stats_root = menu.list(menu.my_root(), "Stats", {"ryanstats"}, "Common stats you may want to edit.")
chat_root = menu.list(menu.my_root(), "Chat", {"ryanchat"}, "Send special chat messages.")
settings_root = menu.list(menu.my_root(), "Settings", {"ryansettings"}, "Settings for Ryan's Menu.")


-- Self Menu --
entities_smashed = {}
entities_chaosed = {}
entities_exploded = {}

menu.divider(self_root, "General")
self_ptfx_root = menu.list(self_root, "PTFX...", {"ryanptfx"}, "Special FX options.")
self_spotlight_root = menu.list(self_root, "Spotlight...", {"ryanspotlight"}, "Attach lights to you or your vehicle.")
self_god_finger_root = menu.list(self_root, "God Finger...", {"ryangodfinger"}, "Control objects with your finger.")
self_forcefield_root = menu.list(self_root, "Forcefield...", {"ryanforcefield"}, "An expanded and enhanced forcefield.")
self_character_root = menu.list(self_root, "Character...", {"ryancharacter"}, "Effects for your character.")
self_crosshair_root = menu.toggle(self_root, "Crosshair", {"ryancrosshair"}, "Add an on-screen crosshair.", function(value) crosshair = value end)

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
    Ryan.PTFX.PlayOnEntityBones(players.user_ped(), Ryan.PTFX.PlayerBones.Head, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

Ryan.PTFX.CreateList(self_ptfx_body_hands_root, function(ptfx)
    if ptfx_disable then return end
    Ryan.PTFX.PlayOnEntityBones(players.user_ped(), Ryan.PTFX.PlayerBones.Hands, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)


Ryan.PTFX.CreateList(self_ptfx_body_feet_root, function(ptfx)
    if ptfx_disable then return end
    Ryan.PTFX.PlayOnEntityBones(players.user_ped(), Ryan.PTFX.PlayerBones.Feet, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

Ryan.PTFX.CreateList(self_ptfx_body_pointer_root, function(ptfx)
    if ptfx_disable then return end
    if Ryan.Globals.PlayerIsPointing then
        Ryan.PTFX.PlayOnEntityBones(players.user_ped(), Ryan.PTFX.PlayerBones.Pointer, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Vehicle PTFX
self_ptfx_vehicle_wheels_root = menu.list(self_ptfx_vehicle_root, "Wheels...", {"ryanptfxwheels"}, "Special FX on the wheels of your vehicle.")
self_ptfx_vehicle_exhaust_root = menu.list(self_ptfx_vehicle_root, "Exhaust...", {"ryanptfxexhaust"}, "Speicla FX on the exhaust of your vehicle.")

Ryan.PTFX.CreateList(self_ptfx_vehicle_wheels_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true)
    if vehicle ~= 0 then
        Ryan.PTFX.PlayOnEntityBones(vehicle, Ryan.PTFX.VehicleBones.Wheels, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

Ryan.PTFX.CreateList(self_ptfx_vehicle_exhaust_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true)
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
    local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped())
    if weapon ~= NULL then
        Ryan.PTFX.PlayAtEntityBoneCoords(weapon, Ryan.PTFX.WeaponBones.Muzzle, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

Ryan.PTFX.CreateList(self_ptfx_weapon_muzzle_flash_root, function(ptfx)
    if ptfx_disable then return end
    local our_ped = players.user_ped()
    if PED.IS_PED_SHOOTING(our_ped) then
        local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(our_ped)
        if weapon ~= NULL then
            Ryan.PTFX.PlayAtEntityBoneCoords(weapon, Ryan.PTFX.WeaponBones.Muzzle, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

Ryan.PTFX.CreateList(self_ptfx_weapon_impact_root, function(ptfx)
    if ptfx_disable then return end
    local impact = v3.new()
    if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), impact) then
        Ryan.PTFX.PlayAtCoords(impact, ptfx[2], ptfx[3], ptfx_color)
    end
end)

-- -- God Finger PTFX
self_ptfx_god_finger_crosshair_root = menu.list(self_ptfx_god_finger_root, "Crosshair...", {"ryanptfxgodfingercrosshair"}, "Special FX wherever you point when using God Finger.")
self_ptfx_god_finger_entities_root = menu.list(self_ptfx_god_finger_root, "Entities...", {"ryanptfxgodfingerentities"}, "Special FX only on entities when using God Finger.")

Ryan.PTFX.CreateList(self_ptfx_god_finger_crosshair_root, function(ptfx)
    if ptfx_disable then return end
    if god_finger_active then
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
forcefield_size = 10
forcefield_force = 1

Ryan.UI.CreateList(self_forcefield_root, "Force", "ryanforcefieldforce", "The type of force to apply.", Ryan.Globals.ForcefieldForces, function(value)
    forcefield_mode = value
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
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        GRAPHICS._DRAW_SPHERE(coords.x, coords.y, coords.z, forcefield_size, Ryan.Globals.HUDColor.r * 255, Ryan.Globals.HUDColor.g * 255, Ryan.Globals.HUDColor.b * 255, 0.3)
    end

    if forcefield_mode ~= "None" then
        local our_ped = players.user_ped()
        local player_coords = ENTITY.GET_ENTITY_COORDS(our_ped)
        local nearby = Ryan.Entity.GetAllNearby(player_coords, forcefield_size, Ryan.Entity.Type.All)
        for _, entity in pairs(nearby) do
            if players.get_vehicle_model(players.user()) == 0 or entity ~= entities.get_user_vehicle_as_handle() then
                pluto_switch forcefield_mode do
                    case "Push": -- Push entities away
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
                        break
                    case "Pull": -- Pull entities in
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
                        break
                    case "Spin": -- Spin entities around
                        if not ENTITY.IS_ENTITY_A_PED(entity) and entity ~= entities.get_user_vehicle_as_handle() then
                            Ryan.Entity.RequestControl(entity)
                            ENTITY.SET_ENTITY_HEADING(entity, ENTITY.GET_ENTITY_HEADING(entity) + 2.5 * forcefield_force)
                        end
                        break
                    case "Up": -- Force entities into air
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
                        break
                    case "Down": -- Force entities into ground
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
                        break
                    case "Smash": -- Smash entities into ground
                        local direction = if util.current_time_millis() % 3000 >= 1250 then -2 else 0.5
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
                        break
                    case "Chaos": -- Chaotic entities
                        if entities_chaosed[entity] == nil or util.current_time_millis() - entities_chaosed[entity] > 1000 then
                            local amount = forcefield_force * 10
                            local force = {
                                x = if math.random(0, 1) == 0 then -amount else amount,
                                y = if math.random(0, 1) == 0 then -amount else amount,
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
                        break
                    case "Explode": -- Explode entities
                        if entities_exploded[entity] == nil then
                            if entity ~= our_ped and entity ~= player_vehicle then
                                local coords = ENTITY.GET_ENTITY_COORDS(entity)
                                FIRE.ADD_EXPLOSION(
                                    coords.x, coords.y, coords.z,
                                    7, 5.0, false, true, 0.0
                                )
                            end
                            entities_exploded[entity] = true
                        end
                    end
                    break
            end
        end
    end
end)

-- -- God Finger
god_finger_active = false
god_finger_target = nil

god_finger_while_pointing = false
god_finger_while_holding_alt = false

god_finger_player_effects = {}
god_finger_vehicle_effects = {}
god_finger_npc_effects = {}
god_finger_world_effects = {}
god_finger_force_effects = {}

menu.divider(self_god_finger_root, "Activate By")
menu.toggle(self_god_finger_root, "Pointing", {"ryangodfingerpointing"}, "If enabled, God Finger activates while pointing.", function(value)
    god_finger_while_pointing = value
end)
menu.toggle(self_god_finger_root, "Left Alt", {"ryangodfingerleftalt"}, "If enabled, God Fingers activates while holding Left Alt.", function(value)
    god_finger_while_holding_alt = value
end)


menu.divider(self_god_finger_root, "Effects")
self_god_finger_player_root = menu.list(self_god_finger_root, "Player", {"ryangodfingerplayer"}, "What to do to players.")
self_god_finger_vehicle_root = menu.list(self_god_finger_root, "Vehicle", {"ryangodfingervehicle"}, "What to do to vehicles.")
self_god_finger_npc_root = menu.list(self_god_finger_root, "NPC", {"ryangodfingernpc"}, "What to do to NPCs.")
self_god_finger_world_root = menu.list(self_god_finger_root, "World", {"ryangodfingerworld"}, "What to create in the world.")
self_god_finger_force_root = menu.list(self_god_finger_root, "Force", {"ryangodfingerforce"}, "The type of force to apply to entities.")


-- -- Player
Ryan.UI.CreateEffectToggle(self_god_finger_player_root, "ryangodfingerplayer", god_finger_player_effects, "Kick", "Kick the player.", true)
Ryan.UI.CreateEffectToggle(self_god_finger_player_root, "ryangodfingerplayer", god_finger_player_effects, "Crash", "Crash the player.", true)
Ryan.UI.CreateEffectToggle(self_god_finger_player_root, "ryangodfingerplayer", god_finger_player_effects, "Super Crash", "Super Crash the player.", true)

-- -- Vehicle
Ryan.UI.CreateVehicleEffectList(self_god_finger_vehicle_root, "ryangodfingervehicle", "", god_finger_vehicle_effects, true, true)
Ryan.UI.CreateEffectToggle(self_god_finger_vehicle_root, "ryangodfingervehicle", god_finger_vehicle_effects, "Steal", "Steal the vehicle.", true)

-- -- World
Ryan.UI.CreateEffectToggle(self_god_finger_world_root, "ryangodfingerworld", god_finger_world_effects, "Nude Yoga", "Spawn a nude NPC doing yoga.", true)
Ryan.UI.CreateEffectToggle(self_god_finger_world_root, "ryangodfingerworld", god_finger_world_effects, "Police Brutality", "Spawn a scene of police brutality.", true)
Ryan.UI.CreateEffectToggle(self_god_finger_world_root, "ryangodfingerworld", god_finger_world_effects, "Fire", "Start a fire.", true)

-- -- NPC
Ryan.UI.CreateNPCEffectList(self_god_finger_npc_root, "ryangodfingernpc", god_finger_npc_effects, true)

-- -- Force
for _, mode in pairs(Ryan.Globals.GodFingerForces) do
    Ryan.UI.CreateEffectToggle(self_god_finger_force_root, "ryangodfingerforce", god_finger_force_effects, mode, "", true)
end

god_finger_player_state = {["kick"] = 0, ["crash"] = 0, ["super_crash"] = 0}
god_finger_vehicle_state = {["steal"] = 0}
god_finger_npc_state = {}
god_finger_world_state = {["nude_yoga"] = 0, ["police_brutality"] = 0, ["fire"] = 0}
god_finger_force_state = {}

god_finger_keybinds = ""
god_finger_keybinds_shown = 0

-- Apply God Finger effects
util.create_tick_handler(function()
    for entity, start_time in pairs(entities_smashed) do
        local time_elapsed = util.current_time_millis() - start_time
        if time_elapsed < 2500 then
            local direction = if time_elapsed > 1250 then -3 else 0.5
            local force = {x = 0, y = 0, z = direction * 4}
            if ENTITY.IS_ENTITY_A_PED(entity) then
                if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
                    PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif entity ~= entities.get_user_vehicle_as_handle() then
                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        end
    end

    ENTITY.SET_ENTITY_PROOFS(players.user_ped(), false, false, Ryan.UI.GetGodFingerActivation(god_finger_force_effects.default) > 0, false, false, false, 1, false)

    god_finger_active = (god_finger_while_pointing     and Ryan.Globals.PlayerIsPointing)
                     or (god_finger_while_holding_alt  and PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Globals.Controls.CharacterWheel))
    
    if not god_finger_active then
        god_finger_target = nil;
        return
    end

    PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.CharacterWheel, true)
    Ryan.UI.DisableGodFingerKeybinds()

    local raycast = nil
    local keybinds = {}
    memory.write_int(memory.script_global(4521801 + 935), NETWORK.GET_NETWORK_TIME())

    raycast = Ryan.Basics.Raycast(500.0, Ryan.Basics.RaycastFlags.Vehicles + Ryan.Basics.RaycastFlags.Peds + Ryan.Basics.RaycastFlags.Objects)
    if raycast.did_hit then
        god_finger_target = raycast.hit_coords
        Ryan.Entity.DrawESP(raycast.hit_entity)

        if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
            local ped = raycast.hit_entity
            util.toast("NPC: " .. ENTITY.GET_ENTITY_MODEL(raycast.hit_entity))

            if PED.IS_PED_A_PLAYER(ped) then
                -- Player
                local keybinds_player = Ryan.UI.GetGodFingerKeybinds(god_finger_player_effects)
                if keybinds_player:len() > 0 then keybinds["Player"] = keybinds_player end

                local player_id = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)
                if Ryan.UI.GetGodFingerActivation(god_finger_player_effects.kick) > 0 then
                    if util.current_time_millis() - god_finger_player_state.kick > 1000 then
                        god_finger_player_state.kick = util.current_time_millis()
                        Ryan.Player.Get(player_id).kick()
                        Ryan.Audio.SelectSound()
                    end
                end
                if Ryan.UI.GetGodFingerActivation(god_finger_player_effects.crash) > 0 then
                    if util.current_time_millis() - god_finger_player_state.crash > 1000 then
                        god_finger_player_state.crash = util.current_time_millis()
                        Ryan.Player.Get(player_id).crash()
                        Ryan.Audio.SelectSound()
                    end
                end
                if Ryan.UI.GetGodFingerActivation(god_finger_player_effects.super_crash) > 0 then
                    if util.current_time_millis() - god_finger_player_state.super_crash > 1000 then
                        god_finger_player_state.super_crash = util.current_time_millis()
                        Ryan.Player.Get(player_id).super_crash(true)
                        Ryan.Audio.SelectSound()
                    end
                end
            else
                -- NPC
                local keybinds_npc = Ryan.UI.GetGodFingerKeybinds(god_finger_npc_effects)
                if keybinds_npc:len() > 0 then keybinds["NPC"] = keybinds_npc end

                Ryan.UI.ApplyNPCEffectList(ped, god_finger_npc_effects, god_finger_npc_state, true)
            end
        end

        if ENTITY.IS_ENTITY_A_VEHICLE(raycast.hit_entity) then
            -- Vehicle
            local keybinds_vehicle = Ryan.UI.GetGodFingerKeybinds(god_finger_vehicle_effects)
            if keybinds_vehicle:len() > 0 then keybinds["Vehicle"] = keybinds_vehicle end

            local vehicle = raycast.hit_entity
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            util.toast("Driver: " .. (if driver ~= 0 then ENTITY.GET_ENTITY_MODEL(driver) else "none"))
    
            Ryan.UI.ApplyVehicleEffectList(vehicle, god_finger_vehicle_effects, god_finger_vehicle_state, PED.IS_PED_A_PLAYER(driver), true)
            if Ryan.UI.GetGodFingerActivation(god_finger_vehicle_effects.steal) > 0 and ENTITY.IS_ENTITY_A_VEHICLE(raycast.hit_entity) then
                if util.current_time_millis() - god_finger_vehicle_state.steal > 1000 then
                    god_finger_vehicle_state.steal = util.current_time_millis()
                    Ryan.Vehicle.Steal(raycast.hit_entity)
                    Ryan.Audio.SelectSound()
                end
            end
        end

        -- Force
        local keybinds_force = Ryan.UI.GetGodFingerKeybinds(god_finger_force_effects)
        if keybinds_force:len() > 0 then keybinds["Force"] = keybinds_force end

        local forces = {
            ["default"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.default) > 0,
            ["push"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.push) > 0,
            ["pull"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.pull) > 0,
            ["spin"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.spin) > 0,
            ["up"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.up) > 0,
            ["down"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.down) > 0,
            ["smash"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.smash) > 0,
            ["chaos"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.chaos) > 0,
            ["explode"] = Ryan.UI.GetGodFingerActivation(god_finger_force_effects.explode) > 0
        }
        for key, _ in pairs(forces) do Ryan.Audio.SelectSoundToggle(forces, god_finger_force_state, key) end

        if forces.default then
            FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 29, 25.0, false, true, 0.0, true)
        elseif forces.push then -- Push entities away
            local entity_coords = ENTITY.GET_ENTITY_COORDS(raycast.hit_entity)
            local force = Ryan.Vector.Normalize(Ryan.Vector.Subtract(entity_coords, ENTITY.GET_ENTITY_COORDS(players.user_ped())))
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
        elseif forces.pull then -- Pull entities in
            local entity_coords = ENTITY.GET_ENTITY_COORDS(raycast.hit_entity)
            local force = Ryan.Vector.Normalize(Ryan.Vector.Subtract(ENTITY.GET_ENTITY_COORDS(players.user_ped()), entity_coords))
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
        elseif forces.spin then -- Spin entities around
            if not ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                Ryan.Entity.RequestControl(raycast.hit_entity)
                ENTITY.SET_ENTITY_HEADING(raycast.hit_entity, ENTITY.GET_ENTITY_HEADING(raycast.hit_entity) + 2.5)
            end
        elseif forces.up then -- Force entities into air
            local force = {x = 0, y = 0, z = 0.5}
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Ryan.Entity.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif entity ~= entities.get_user_vehicle_as_handle() then
                Ryan.Entity.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif forces.down then -- Force entities into ground
            local force = {x = 0, y = 0, z = -2}
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Ryan.Entity.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif entity ~= entities.get_user_vehicle_as_handle() then
                Ryan.Entity.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif forces.smash then -- Smash entities into ground
            if entities_smashed[raycast.hit_entity] == nil or util.current_time_millis() - entities_smashed[raycast.hit_entity] > 2500 then
                Ryan.Entity.RequestControl(raycast.hit_entity)
                entities_smashed[raycast.hit_entity] = util.current_time_millis()
            end
        elseif forces.chaos then -- Chaotic entities
            if entities_chaosed[raycast.hit_entity] == nil or util.current_time_millis() - entities_chaosed[raycast.hit_entity] > 1000 then
                local amount = 20
                local force = {
                    x = if math.random(0, 1) == 0 then -amount else amount,
                    y = if math.random(0, 1) == 0 then -amount else amount,
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
        elseif forces.explode then -- Explode entities
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

        raycast = Ryan.Basics.Raycast(500.0, Ryan.Basics.RaycastFlags.World)
        if raycast.did_hit then
            -- World
            local keybinds_world = Ryan.UI.GetGodFingerKeybinds(god_finger_world_effects)
            if keybinds_world:len() > 0 then keybinds["World"] = keybinds_world end

            if Ryan.UI.GetGodFingerActivation(god_finger_world_effects.nude_yoga) > 0 then
                if util.current_time_millis() - god_finger_world_state.nude_yoga > 2000 then
                    god_finger_world_state.nude_yoga = util.current_time_millis()

                    local raycast = Ryan.Basics.Raycast(50.0)
                    if raycast.did_hit then
                        local topless, acult = util.joaat("a_f_y_topless_01"), util.joaat("a_m_y_acult_01")
                        Ryan.Basics.RequestModel(topless); Ryan.Basics.RequestAnimations("amb@world_human_yoga@female@base")
                        Ryan.Basics.RequestModel(acult); Ryan.Basics.RequestAnimations("switch@trevor@jerking_off")

                        local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())
                        local ped = entities.create_ped(0, topless, raycast.hit_coords, heading)
                        PED.SET_PED_COMPONENT_VARIATION(ped, 8, 1, -1, 0)
                        TASK.TASK_PLAY_ANIM(ped, "amb@world_human_yoga@female@base", "base_a", 8.0, 0, -1, 9, 0, false, false, false)

                        local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())
                        local ped = entities.create_ped(0, acult, Ryan.Vector.Add(raycast.hit_coords, {x = -3, y = 0, z = 0}), heading)
                        PED.SET_PED_COMPONENT_VARIATION(ped, 4, 0, 0, 0)
                        PED.SET_PED_COMPONENT_VARIATION(ped, 8, 0, 0, 0)
                        TASK.TASK_PLAY_ANIM(ped, "switch@trevor@jerking_off", "trev_jerking_off_loop", 8.0, 0, -1, 9, 0, false, false, false)
                        
                        Ryan.Basics.FreeModel(topless)
                        Ryan.Basics.FreeModel(acult)
                    end
                end
            end

            if Ryan.UI.GetGodFingerActivation(god_finger_world_effects.police_brutality) > 0 then
                if util.current_time_millis() - god_finger_world_state.police_brutality > 2000 then
                    god_finger_world_state.police_brutality = util.current_time_millis()

                    local raycast = Ryan.Basics.Raycast(50.0)
                    if raycast.did_hit then
                        local famfor, cop = util.joaat("g_m_y_famfor_01"), util.joaat("s_f_y_cop_01")
                        Ryan.Basics.RequestModel(famfor); Ryan.Basics.RequestAnimations("missheistdockssetup1ig_13@main_action")
                        Ryan.Basics.RequestModel(cop); Ryan.Basics.RequestAnimations("move_m@intimidation@cop@unarmed")

                        local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())

                        civilians = {}
                        for i = 1, 3 do
                            local ped = entities.create_ped(0, famfor, Ryan.Vector.Add(raycast.hit_coords, {x = i, y = math.random(-1, 1), z = 0}), heading)
                            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, famfor)
                            PED.SET_PED_COMPONENT_VARIATION(ped, 8, 1, -1, 0)
                            animations = {"guard_beatup_mainaction_dockworker", "guard_beatup_mainaction_guard1", "guard_beatup_mainaction_guard2"}
                            TASK.TASK_PLAY_ANIM(ped, "missheistdockssetup1ig_13@main_action", animations[i], 8.0, 0, -1, 9, 0, false, false, false)
                            
                            table.insert(civilians, ped)
                        end

                        util.yield(750)

                        cops = {}
                        for i = 1, 3 do
                            local cop = entities.create_ped(0, cop, Ryan.Vector.Add(raycast.hit_coords, {x = 3 + i, y = math.random(-1, 1), z = 0}), heading)
                            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, cop)
                            PED.SET_PED_COMPONENT_VARIATION(ped, 8, 1, -1, 0)
                            TASK.TASK_PLAY_ANIM(ped, "move_m@intimidation@cop@unarmed", "idle", 8.0, 0, -1, 9, 0, false, false, false)

                            WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_appistol"), 1000, false, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)

                            Ryan.Entity.FaceEntity(ped, civilian, false)
                            Ryan.Entity.FaceEntity(civilians[i], ped, false)

                            table.insert(cops, ped)
                        end

                        util.yield(750)

                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, util.joaat("g_m_y_famfor_01"), util.joaat("s_f_y_cop_01"))
                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, util.joaat("s_f_y_cop_01"), util.joaat("g_m_y_famfor_01"))
                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, util.joaat("s_f_y_cop_01"), util.joaat("s_f_y_cop_01"))
                        for i = 1, #cops do TASK.TASK_COMBAT_PED(cops[i], civilians[i], 0, 16) end

                        Ryan.Basics.FreeModel(famfor)
                        Ryan.Basics.FreeModel(cop)
                    end
                end
            end

            if Ryan.UI.GetGodFingerActivation(god_finger_world_effects.fire) > 0 then
                if util.current_time_millis() - god_finger_world_state.fire > 1000 then
                    god_finger_world_state.fire = util.current_time_millis()

                    local raycast = Ryan.Basics.Raycast(250.0)
                    if raycast.did_hit then
                        if raycast.hit_entity then FIRE.START_ENTITY_FIRE(raycast.hit_entity) end
                        FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 3, 100.0, false, false, 0.0)
                    end
                end
            end
        end
    end
    

    local world_keybind_before = god_finger_keybinds:find("World:")
    local non_world_keybind_now = false
    for category, _ in pairs(keybinds) do
        if category ~= "World" then non_world_keybind_now = true end
    end

    god_finger_keybinds = ""
    for category, effects in pairs(keybinds) do
        god_finger_keybinds = god_finger_keybinds .. "<b>" .. category .. ":</b>\n" .. effects .. "\n\n"
    end

    local last_shown = util.current_time_millis() - god_finger_keybinds_shown
    if god_finger_keybinds:len() > 0 then
        --[[if non_world_keybind_now or last_shown > 500 then]]
            util.show_corner_help(god_finger_keybinds:sub(0, god_finger_keybinds:len() - 2))
            god_finger_keybinds_shown = util.current_time_millis()
        --[[end]]
    else
        if last_shown > 500--[[ or world_keybind_before]] then
            util.show_corner_help("No God Finger effects available.")
        end
    end
end)

-- -- Spotlight
spotlight_offset = 3.0
spotlight_intensity = 1

menu.action(self_spotlight_root, "Add To Body", {"ryanspotlightbody"}, "Adds spotlights to your body.", function()
    local our_ped = players.user_ped()
    if our_ped ~= 0 then
        Ryan.Entity.AddSpotlight(our_ped, spotlight_offset, spotlight_intensity)
    end
end)

menu.action(self_spotlight_root, "Add To Vehicle", {"ryanspotlightvehicle"}, "Adds spotlights to your vehicle.", function()
    local player_id, our_ped = players.user(), players.user_ped()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= 0 then
        Ryan.Entity.AddSpotlight(vehicle, spotlight_offset, spotlight_intensity)
    end
end)

menu.divider(self_spotlight_root, "Options")
menu.slider(self_spotlight_root, "Offset", {"ryanspotlightoffset"}, "How far the lights are away from the model.", 1, 100, 30, 5, function(value)
    spotlight_offset = value / 10.0
end)
menu.slider(self_spotlight_root, "Intensity", {"ryanspotlightintensity"}, "How bright the light is.", 1, 50, 1, 1, function(value)
    spotlight_intensity = value
end)
menu.action(self_spotlight_root, "Remove All", {"ryanspotlightremove"}, "Removes previously added spotlights.", function()
    Ryan.Entity.DetachAll(players.user_ped())
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= 0 then
        Ryan.Entity.DetachAll(vehicle)
    end
end)

-- -- Character
ghost_mode = false
menu.toggle(self_character_root, "Ghost Mode", {"ryanghost"}, "Become entirely invisible to other players.", function(value)
    ghost_mode = value
    menu.trigger_commands("invisibility " .. (if value then "remote" else "off"))
    menu.trigger_commands("otr " .. (if value then "on" else "off"))
    if value then Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Ghost Mode", "Ghost Mode enabled. Players can no longer see you.")
    else Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Orange, "Ghost Mode", "Ghost Mode disabled. Players can see you!") end
end)
util.create_tick_handler(function()
    if ghost_mode then util.draw_debug_text("Ghost Mode") end
end)

menu.action(self_character_root, "Become Nude", {"ryannude"}, "Make yourself a stripper with her tits out.", function()
    local topless = util.joaat("a_f_y_topless_01")
    Ryan.Basics.RequestModel(topless)

    local ourself = Ryan.Player.Self()
    local vehicle_id = if players.get_vehicle_model(ourself.id) ~= 0 then PED.GET_VEHICLE_PED_IS_IN(ourself.ped_id, false) else 0
    local seat_id = ourself.get_vehicle_seat()

    if vehicle_id ~= 0 then Ryan.Basics.Teleport(Ryan.Vector.Add(ourself.get_coords(), {x = 0, y = 0, z = 5})) end
    PLAYER.SET_PLAYER_MODEL(ourself.id, topless)
    util.yield(250)
    PED.SET_PED_COMPONENT_VARIATION(ourself.ped_id, 8, 1, -1, 0)
    if vehicle_id ~= 0 then PED.SET_PED_INTO_VEHICLE(ourself.ped_id, vehicle_id, seat_id) end

    Ryan.Basics.FreeModel(topless)
end)


menu.divider(self_root, "Vehicle")

-- -- Seats
self_seats_root = menu.list(self_root, "Seats...", {"ryanseats"}, "Allows you to switch seats in your current vehicle.")

switch_seats_actions = {}
switch_seats_notice = nil
util.create_tick_handler(function()
    local vehicle_model = players.get_vehicle_model(players.user())
    if vehicle_model ~= 0 then
        local vehicle_id = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true)
        local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vehicle_model)
        if seats ~= #switch_seats_actions then
            for _, action in pairs(switch_seats_actions) do menu.delete(action) end
            switch_seats_actions = {}
            for seat = -1, seats - 2 do
                table.insert(switch_seats_actions, menu.action(self_seats_root, Ryan.Basics.SeatName(seat), {"ryanseat" .. (seat + 2)}, "Switch to " .. Ryan.Basics.SeatName(seat) .. ".", function()
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle_id, seat)
                end))
            end
        else
            for seat = -1, seats - 2 do
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle_id, seat) ~= 0 then
                    menu.set_menu_name(switch_seats_actions[seat + 2], Ryan.Basics.SeatName(seat) .. " [Taken]")
                else
                    menu.set_menu_name(switch_seats_actions[seat + 2], Ryan.Basics.SeatName(seat))
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

-- -- E-Brake
ebrake = false
menu.toggle(self_root, "E-Brake", {"ryanebrake"}, "Makes your vehicle drift while holding Shift.", function(value)
    if not value then Ryan.Vehicle.SetNoGrip(vehicle, false) end
    ebrake = value
end)

util.create_tick_handler(function()
    if ebrake then
        local our_ped = players.user_ped()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(our_ped, false)
        if vehicle ~= 0 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) == our_ped then
            Ryan.Vehicle.SetNoGrip(vehicle, PAD.IS_CONTROL_PRESSED(0, Ryan.Globals.Controls.Sprint))
        end
    end
end)

-- -- Auto-Repair
menu.toggle_loop(self_root, "Auto-Repair", {"ryanautorepair"}, "Keeps your vehicle in mint condition for all players.", function()
    local vehicle = entities.get_user_vehicle_as_handle()

    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), Ryan.Globals.Tasks.EnterVehicle)
        or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), Ryan.Globals.Tasks.ExitVehicle)
        or not VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) then return end

    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
    VEHICLE.SET_VEHICLE_FIXED(vehicle)
end)


-- World Menu --
menu.divider(world_root, "General")
world_all_npcs_root = menu.list(world_root, "All NPCs...", {"ryanallnpcs"}, "Affects all NPCs in the world.")
world_collectibles_root = menu.list(world_root, "Collectibles...", {"ryancollectibles"}, "Useful presets to teleport to.")

-- -- All NPCs
all_npcs_include_drivers = false
all_npcs_effects = {}
all_npcs_state = {}

menu.divider(world_all_npcs_root, "Include")
menu.toggle(world_all_npcs_root, "Drivers", {"ryanallnpcsdrivers"}, "If enabled, NPCs will get out of their vehicles.", function(value)
    all_npcs_include_drivers = value
end, false)

menu.divider(world_all_npcs_root, "Effects")
Ryan.UI.CreateNPCEffectList(world_all_npcs_root, "ryanallnpcs", all_npcs_effects, false)

util.create_tick_handler(function()
    if all_npcs_mode ~= "Off" then
        local scenario = ""
        pluto_switch all_npcs_mode do
            case "Musician":
                scenario = "WORLD_HUMAN_MUSICIAN"
                break
            case "Paparazzi":
                scenario = "WORLD_HUMAN_PAPARAZZI"
                break
            case "Human Statue":
                scenario = "WORLD_HUMAN_HUMAN_STATUE"
                break
            case "Janitor":
                scenario = "WORLD_HUMAN_JANITOR"
                break
        end

        local player_coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        for _, ped in pairs(Ryan.Entity.GetAllNearby(player_coords, 250, Ryan.Entity.Type.Peds)) do
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            if not PED.IS_PED_A_PLAYER(ped) and (all_npcs_include_drivers or vehicle == 0) then
                if vehicle ~= 0 then
                    ENTITY.SET_ENTITY_VELOCITY(vehicle, 0.0, 0.0, 0.0)
                    TASK.TASK_EVERYONE_LEAVE_VEHICLE(vehicle)
                end

                Ryan.UI.ApplyNPCEffectList(ped, all_npcs_effects, all_npcs_state, false)
            end
        end
    end
    util.yield(250)
end)

-- -- Collectibles
world_action_figures_root = menu.list(world_collectibles_root, "Action Figures...", {"ryanactionfigures"}, "Every action figure in the game.")
Ryan.UI.CreateTeleportList(world_action_figures_root, "Action Figure", Ryan.Globals.ActionFigures)

world_signal_jammers_root = menu.list(world_collectibles_root, "Signal Jammers...", {"ryansignaljammers"}, "Every signal jammer in the game.")
Ryan.UI.CreateTeleportList(world_signal_jammers_root, "Signal Jammer", Ryan.Globals.SignalJammers)

world_playing_cards_root = menu.list(world_collectibles_root, "Playing Cards...", {"ryanplayingcards"}, "Every playing card in the game.")
Ryan.UI.CreateTeleportList(world_playing_cards_root, "Playing Card", Ryan.Globals.PlayingCards)

world_movie_props_root = menu.list(world_collectibles_root, "Movie Props...", {"ryanmovieprops"}, "Every movie prop in the Solomon Richards quest.")
Ryan.UI.CreateTeleportList(world_movie_props_root, "Movie Prop", Ryan.Globals.MovieProps)

world_slasher_root = menu.list(world_collectibles_root, "The Slasher...", {"ryanslasher"}, "Everything needed to activate the Slasher event.")
menu.divider(world_slasher_root, "Step 1")
Ryan.UI.CreateTeleportList(world_slasher_root, "Slasher Clue", Ryan.Globals.SlasherClues)
menu.divider(world_slasher_root, "Step 2")
Ryan.UI.CreateTeleportList(world_slasher_root, "Slasher Van", Ryan.Globals.SlasherVans)
menu.divider(world_slasher_root, "Step 3")
slasher_spawn = menu.action(world_slasher_root, "Slasher Spawn", {"ryanslasherspawn"}, "Teleports to the Slasher's spawn location", function(click_type)
    menu.show_warning(slasher_spawn, click_type, "You must be on foot between 7pm and 5am for the Slasher to spawn here.", function()
        Ryan.Player.Self().teleport({x = Ryan.Globals.SlasherFinale[1], y = Ryan.Globals.SlasherFinale[2], z = Ryan.Globals.SlasherFinale[3]}, false)
    end)
end)

world_treasure_hunt_root = menu.list(world_collectibles_root, "Treasure Hunt...", {"ryantreasures"}, "Every treasure in the Treasture Hunt.")
Ryan.UI.CreateTeleportList(world_treasure_hunt_root, "Treasure", Ryan.Globals.Treasures)

world_usb_sticks_root = menu.list(world_collectibles_root, "USB Sticks...", {"ryanusbsticks"}, "Every USB Stick containing bonus music.")
Ryan.UI.CreateTeleportList(world_usb_sticks_root, "USB Stick", Ryan.Globals.USBSticks)

-- -- All Entities Visible
menu.toggle_loop(world_root, "All Entities Visible", {"ryannoinvisible"}, "Makes all invisible entities visible again.", function()
    for _, player in pairs(Ryan.Player.List(false, true, true)) do
        ENTITY.SET_ENTITY_ALPHA(player.ped_id, 255)
        ENTITY.SET_ENTITY_VISIBLE(player.ped_id, true, 0)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player.ped_id, true)
        if vehicle ~= 0 then
            ENTITY.SET_ENTITY_ALPHA(vehicle, 255)
            ENTITY.SET_ENTITY_VISIBLE(vehicle, true, 0)
        end
    end
end)

-- -- Fireworks
firework_coords = nil
menu.toggle(world_root, "Fireworks Show", {"ryanfireworkshow"}, "A nice display of liberty where you're standing.", function(value)
    firework_coords = if value then ENTITY.GET_ENTITY_COORDS(players.user_ped()) else nil
end)
util.create_tick_handler(function()
    if firework_coords ~= nil then
        Ryan.Basics.DoFireworks(firework_coords, {x = math.random(-150, 150), y = math.random(-200, 50), z = math.random(-25, 25)})

        if math.random(1, 10) == 1 then
            local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
            Ryan.Basics.DoFireworks(firework_coords, Ryan.Vector.Add(offset, {x = 8, y = 8, z = 0}))
            Ryan.Basics.DoFireworks(firework_coords, Ryan.Vector.Add(offset, {x = -8, y = 8, z = 0}))
            Ryan.Basics.DoFireworks(firework_coords, Ryan.Vector.Add(offset, {x = 8, y = -8, z = 0}))
            Ryan.Basics.DoFireworks(firework_coords, Ryan.Vector.Add(offset, {x = -8, y = -8, z = 0}))
        end
        if math.random(1, 10) == 2 then
            local offset = {x = math.random(-75, 75), y = math.random(-75, 75), z = math.random(-25, 25)}
            for i = 1, math.random(3, 6) do
                util.yield(math.random(75, 500))
                Ryan.Basics.DoFireworks(firework_coords, Ryan.Vector.Add(offset, {x = 8, y = i + 8, z = 0}))
                Ryan.Basics.DoFireworks(firework_coords, Ryan.Vector.Add(offset, {x = 8, y = -i - 8, z = 0}))
            end
        end

        util.yield(math.random(150, 650))
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

-- -- Remove
remove_modes = {"None", "Cops", "Cayo Perico Guards", "Casino Guards", "Doomsday Guards"}
Ryan.UI.CreateList(world_root, "Remove", "ryanremove", "Clears the world of certain types of peds.", remove_modes, function(value)
    remove_mode = value
end)
util.create_tick_handler(function()
    if not CUTSCENE.IS_CUTSCENE_ACTIVE() then
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        for _, entity in pairs(Ryan.Entity.GetAllNearby(coords, 500, Ryan.Entity.Type.Peds)) do
            if ENTITY.IS_ENTITY_A_PED(entity) then
                pluto_switch remove_mode do
                    case "Cops":
                        for _, ped_type in pairs(Ryan.Globals.PedGroups.LawEnforcement) do
                            if PED.GET_PED_TYPE(entity) == ped_type then
                                Ryan.Entity.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                util.toast("Removed a cop.")
                            end
                        end
                        break
                    case "Cayo Perico Guards":
                        for _, ped_hash in pairs(Ryan.Globals.PedModels.CayoPericoHeist) do
                            if ENTITY.GET_ENTITY_MODEL(entity) == ped_hash then
                                Ryan.Entity.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                util.toast("Removed a Cayo Perico guard.")
                            end
                        end
                    case "Casino Guards":
                        for _, ped_hash in pairs(Ryan.Globals.PedModels.CasinoHeist) do
                            if ENTITY.GET_ENTITY_MODEL(entity) == ped_hash then
                                Ryan.Entity.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                util.toast("Removed a Casino guard.")
                            end
                        end
                    case "Doomsday Guards":
                        for _, ped_hash in pairs(Ryan.Globals.PedModels.DoomsdayHeist) do
                            if ENTITY.GET_ENTITY_MODEL(entity) == ped_hash then
                                Ryan.Entity.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                util.toast("Removed a Doomsday guard.")
                            end
                        end
                end
            end
        end
    end
    util.yield(250)
end)


menu.divider(world_root, "Vehicle")

-- -- All Vehicles
world_all_vehicles_root = menu.list(world_root, "All Vehicles...", {"ryanallvehicles"}, "Control the vehicles around you.")

all_vehicles_include_npcs = true
all_vehicles_include_players = false
all_vehicles_include_friends = false
all_vehicles_include_own = false
all_vehicles_effects = {}

menu.divider(world_all_vehicles_root, "Include")
menu.toggle(world_all_vehicles_root, "NPCs", {"ryanallvehiclesnpcs"}, "If enabled, player-driven vehicles are affected too.", function(value)
    all_vehicles_include_npcs = value
end, true)
menu.toggle(world_all_vehicles_root, "Players", {"ryanallvehiclesplayers"}, "If enabled, player-driven vehicles are affected too.", function(value)
    all_vehicles_include_friends = value
end)
menu.toggle(world_all_vehicles_root, "Friends", {"ryanallvehiclesfriends"}, "If enabled, friends' vehicles are affected too.", function(value)
    all_vehicles_include_players = value
end)
menu.toggle(world_all_vehicles_root, "Personal Vehicle", {"ryanallvehiclesown"}, "If enabled, your current vehicle is affected too.", function(value)
    all_vehicles_include_own = value
end)


menu.divider(world_all_vehicles_root, "Effects")
Ryan.UI.CreateVehicleEffectList(world_all_vehicles_root, "ryanall", "", all_vehicles_effects, false, false)
menu.toggle(world_all_vehicles_root, "Flee", {"ryanallflee"}, "Makes NPCs flee you.", function(value)
    all_vehicles_effects.flee = value
end)
menu.toggle(world_all_vehicles_root, "Blind", {"ryanallblind"}, "Makes NPCs blind and aggressive.", function(value)
    all_vehicles_effects.blind = value
end)

all_vehicles_state = {}

util.create_tick_handler(function()
    local player_coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped())

    local vehicles = Ryan.Entity.GetAllNearby(player_coords, 250, Ryan.Entity.Type.Vehicles)
    for _, vehicle in pairs(vehicles) do
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        local player_id = PED.IS_PED_A_PLAYER(driver) and Ryan.Player.ByPedId(driver)

        if all_vehicles_include_own or vehicle ~= entities.get_user_vehicle_as_handle() then
            if (all_vehicles_include_players and player_id ~= nil and (all_vehicles_include_friends or not players.get_tags_string(player_id):find("F")))
            or (all_vehicles_include_npcs and not is_a_player) then
                Ryan.UI.ApplyVehicleEffectList(vehicle, all_vehicles_effects, all_vehicles_state, is_a_player, false)

                -- Flee
                if all_vehicles_effects.flee and not is_a_player and all_vehicles_state[vehicle].flee ~= true then
                    TASK.TASK_SMART_FLEE_PED(driver, players.user_ped(), 500.0, -1, false, false)
                    all_vehicles_state[vehicle].flee = true
                end

                -- Blind
                if all_vehicles_effects.blind and not is_a_player and (all_vehicles_state[vehicle].blind ~= true or math.random(1, 10) >= 8) then
                    Ryan.Vehicle.MakeBlind(vehicle)
                    all_vehicles_state[vehicle].blind = true
                end
            end
        end
    end

    util.yield(500)
end)

-- -- Enter Closest Vehicle
enter_closest_vehicle = menu.action(world_root, "Enter Closest Vehicle", {"ryandrivevehicle"}, "Teleports into the closest vehicle.", function()
    local closest_vehicle = Ryan.Vehicle.GetClosest(ENTITY.GET_ENTITY_COORDS(players.user_ped(), true))
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(closest_vehicle, -1)
    
    if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, -1) then
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), closest_vehicle, -1)
        util.toast("Teleported into the closest vehicle.")
    else
        if PED.GET_PED_TYPE(driver) >= 4 then
            entities.delete_by_handle(driver)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), closest_vehicle, -1)
            util.toast("Teleported into the closest vehicle.")
        elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(closest_vehicle) then
            for i = 0, 10 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, i) then
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), closest_vehicle, i)
                    break
                end
            end
            util.toast("Teleported into the closest vehicle.")
        else
            util.toast("No nearby vehicles found.")
        end
        
    end
end)

draw_closest_vehicle_esp = false
menu.on_focus(enter_closest_vehicle, function() draw_closest_vehicle_esp = true end)
menu.on_blur(enter_closest_vehicle, function() draw_closest_vehicle_esp = false end)

util.create_tick_handler(function()
    if draw_closest_vehicle_esp then
        local closest_vehicle = Ryan.Vehicle.GetClosest(ENTITY.GET_ENTITY_COORDS(players.user_ped(), true))
        if closest_vehicle ~= 0 then Ryan.Entity.DrawESP(closest_vehicle) end
    end
end)


-- Session Menu --
menu.divider(session_root, "General")
session_dox_root = menu.list(session_root, "Dox...", {"ryandox"}, "Shares information players probably want private.")
session_nuke_root = menu.list(session_root, "Nuke...", {"ryannuke"}, "Plays a siren, timer, and bomb with additional earrape.")
session_crash_all_root = menu.list(session_root, "Crash All...", {"ryancrashall"}, "The ultimate session crash.")
sassion_antihermit_root = menu.list(session_root, "Anti-Hermit...", {"ryanantihermit"}, "Handle players that never seem to go outside.")
session_max_players_root = menu.list(session_root, "Max Players...", {"ryanmax"}, "Kicks players when above a certain limit.")

-- -- Nuke
nuke_spam_enabled = false
nuke_spam_message = "Get Ryan's Menu for Stand!"

menu.action(session_nuke_root, "Go", {"ryannukego"}, "Starts the nuke.", function()
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
    if nuke_spam_enabled then Ryan.Session.SpamChat(nuke_spam_message, 100) end
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

menu.action(session_crash_all_root, "Stand Crash", {"ryancrashallstand"}, "Let the crashing commence.", function()
    for _, player in pairs(Ryan.Player.List(false, crash_all_friends, crash_all_modders)) do
        if crash_all_modders or not players.is_marked_as_modder(player_id) then
            Ryan.Player.Get(player_id).crash()
            util.yield(500)
        end
    end
end)

menu.action(session_crash_all_root, "Super Crash", {"ryancrashallsuper"}, "Let the crashing commence, epicly.", function()
    local player_names = {}
    local blocked_players = {}
    for _, player in pairs(Ryan.Player.List(false, true, true)) do
        if (not crash_all_friends and players.get_tags_string(player.id):find("F"))
        or (not crash_all_modders and players.is_marked_as_modder(player.id)) then
            player.block_syncs(true)
            table.insert(blocked_players, player.id)
        else
            table.insert(player_names, player.name)
        end
    end
    
    for _, player_name in pairs(player_names) do
        local player = Ryan.Player.ByName(player_name)
        if player ~= nil then
            player.super_crash(false)
        end
    end

    for _, player_id in pairs(blocked_players) do
        Ryan.Player.Get(player_id).block_syncs(false)
    end
end)

menu.divider(session_crash_all_root, "Options")
menu.toggle(session_crash_all_root, "Include Modders", {"ryancrashallmodders"}, "If enabled, modders are included.\nRecommended only when using Super Crash.", function(value)
    crash_all_modders = value
end)
menu.toggle(session_crash_all_root, "Include Friends", {"ryancrashallfriends"}, "If enabled, friends are included.", function(value)
    crash_all_friends = value
end)

-- -- Anti-Hermit
antihermit_time = 300000

Ryan.UI.CreateList(sassion_antihermit_root, "Mode", "ryanantihermit", "What to do with the hermits.", Ryan.Globals.AntihermitModes, function(value)
    antihermit_mode = value
end)
menu.slider(sassion_antihermit_root, "Time (Minutes)", {"ryanantihermittime"}, "How long, in minutes, to let players stay inside.", 1, 15, 5, 1, function(value)
    antihermit_time = value * 60000
end)

hermits = {}
hermit_list = {}
util.create_tick_handler(function()
    if not Ryan.Globals.PlayerIsSwitchingSessions then
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
                        hermits[player_id] = util.current_time_millis() - (antihermit_time * 0.7)
                        hermit_list[player_id] = nil
                    elseif util.current_time_millis() - hermits[player_id] >= antihermit_time then
                        hermits[player_id] = util.current_time_millis() - (antihermit_time * 0.7)
                        hermit_list[player_id] = true
                        if antihermit_mode ~= "Off" then
                            local player = Ryan.Player.Get(player_id)
                            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Anti-Hermit", player_name .. " has been inside for 5 minutes. Now doing: " .. antihermit_mode .. "!")
                            player.spam_sms("You've been inside too long. Stop being weird and play the game!", 1500)
                            pluto_switch antihermit_mode do
                                case "Teleport Outside":
                                    menu.trigger_commands("apt1" .. player_name)
                                    break
                                case "Kick":
                                    player.kick(player_id)
                                    break
                                case "Crash":
                                    player.crash(player_id)
                                    break
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
max_players_amount = 0

max_players_prefer_highest_kd = true
max_players_prefer_richest = false
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
        menu.trigger_commands("ryanmaxprefermoney off")
        if not max_players_include_modders then menu.trigger_commands("ryanmaxincludemodders on") end
    end
    max_players_prefer_modders = value
end)
menu.toggle(session_max_players_root, "Richest", {"ryanmaxpreferrichest"}, "Kicks players with the highest balance first.", function(value)
    if value then
        menu.trigger_commands("ryanmaxpreferkd off")
        menu.trigger_commands("ryanmaxprefermodders off")
    end
    max_players_prefer_richest = value
end)
menu.toggle(session_max_players_root, "Highest K/D", {"ryanmaxpreferhighestkd"}, "Kicks players with the most money first.", function(value)
    if value then
        menu.trigger_commands("ryanmaxprefermoney off")
        menu.trigger_commands("ryanmaxprefermodders off")
    end
    max_players_prefer_highest_kd = value
end)

menu.divider(session_max_players_root, "Include")
menu.toggle(session_max_players_root, "Modders", {"ryanmaxincludemodders"}, "If enabled, modders will be kicked.", function(value)
    if not value then menu.trigger_commands("ryanmaxprefermodders off") end
    max_players_include_modders = value
end)
menu.toggle(session_max_players_root, "Friends", {"ryanmaxincludefriends"}, "If enabled, friends will be kicked.", function(value)
    max_players_include_modders = value
end)

util.create_tick_handler(function()
    if max_players_amount ~= 0 then
        local player_list = players.list()
        if #player_list > max_players_amount then
            if max_players_prefer_modders or max_players_prefer_richest or max_players_prefer_highest_kd then
                table.sort(player_list, function(player_1, player_2)
                    if max_players_prefer_modders then
                        return (if players.get_tags_string(player_1):find("M") then 1 else 0) > (if players.get_tags_string(player_2):find("M") then 1 else 0)
                    elseif max_players_prefer_richest then
                        return players.get_money(player_1) > players.get_money(player_2)
                    elseif max_players_prefer_highest_kd then
                        return players.get_kd(player_1) > players.get_kd(player_2)
                    end
                end)
            end

            local kick_count = #player_list - max_players_amount
            local kicked = 0
            for i = 1, #player_list do
                local can_kick = (max_players_include_modders or not players.get_tags_string(player_list[i]):find("M"))
                             and (max_players_include_friends or not players.get_tags_string(player_list[i]):find("F"))
                if player_list[i] ~= players.user() and can_kick and kicked < kick_count then
                    --local reason = if max_players_prefer_highest_kd then ("having a " .. string.format("%.1f", players.get_kd(player_list[i])) .. " K/D") else ("being a modder")
                    local player = Ryan.Player.Get(player_list[i])
                    local reason = "no reason"
                    if max_players_prefer_modders then reason = "being a modder"
                    elseif max_players_prefer_richest then reason = "having $" .. Ryan.Basics.FormatNumber(players.get_money(player_list[i]))
                    elseif max_players_prefer_highest_kd then reason = "having a " .. string.format("%.1f", players.get_kd(player_list[i])) .. " K/D" end
                    Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Max Players", "Kicking " .. players.get_name(player_list[i]) .. " for " .. reason .. ".")
                    player.kick()
                    kicked = kicked + 1
                end
            end
        end
    end
    util.yield(1000)
end)

-- -- NASA Satellite
Ryan.Trolling.CreateNASAMenu(session_root, nil)

-- -- Turn Into Animals
turn_all_into_animals = false
menu.toggle(session_root, "Turn Into Animals", {"ryananimalall"}, "Turns all players into a random animal.", function(value) turn_all_into_animals = value end)

util.create_tick_handler(function()
    if turn_all_into_animals then
        for _, player in pairs(Ryan.Player.List(true, true, true)) do
            player.turn_into_animal()
            util.yield(30000)
        end
    end
end)


-- Vehicle
menu.divider(session_root, "Vehicle")

-- -- Trolling
session_vehicle_trolling_root = menu.list(session_root, "Trolling...", {"ryantpvehicles"}, "Forces every vehicle into an area.")
    
menu.toggle_loop(session_vehicle_trolling_root, "Teleport To Me", {"ryantpme"}, "Teleports them to your location.", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    for _, player_id in pairs(players.list(false)) do
        local player = Ryan.Player.Get(player_id)
        if Ryan.Vector.Distance(ENTITY.GET_ENTITY_COORDS(player.ped_id), coords) > 33.33 then
            player.teleport_vehicle(Ryan.Vector.Add(coords, {x = math.random(-10, 10), y = math.random(-10, 10), z = 0}))
        end
    end
    util.yield(1000)
end)

menu.toggle_loop(session_vehicle_trolling_root, "Delete", {"ryandelete"}, "Deletes their vehicle.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = if players.get_vehicle_model(player_id) ~= 0 then PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.Get(player_id).ped_id, false) else 0
        if vehicle ~= 0 then
            Ryan.Entity.RequestControl(vehicle, false)
            entities.delete_by_handle(vehicle)
        end
    end
end)

-- -- Mk II
mk2_chaos_notice = 0
mk2_ban_notice = 0
mk2_ban_evaders = {}
mk2_ban_warnings = {}

mk2_modes = {"Normal", "Banned", "Chaos"}
Ryan.UI.CreateList(session_root, "Mk II", "ryanmk2", "How Oppressor Mk IIs are handled in the session.", mk2_modes, function(value)
    if mk2_mode == "Banned" then mk2_ban_notice = 0 end
    if mk2_mode == "Chaos" then mk2_chaos_notice = 0 end
    mk2_mode = value
end)

util.create_tick_handler(function()
    pluto_switch mk2_mode do
        case "Banned":
            if util.current_time_millis() - mk2_ban_notice >= 300000 then
                Ryan.Basics.SendChatMessage("This session is in Mk II Ban mode! Go ahead, try and use one.")
                mk2_ban_notice = util.current_time_millis()
            end

            local oppressor2 = util.joaat("oppressor2")
            local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            for _, vehicle in pairs(Ryan.Entity.GetAllNearby(coords, 9999, Ryan.Entity.Type.Vehicle)) do
                if VEHICLE.IS_VEHICLE_MODEL(vehicle, oppressor2) then
                    Ryan.Entity.RequestControl(vehicle, false)
                    entities.delete_by_handle(vehicle)
                end
            end

            for _, player_id in pairs(players.list()) do
                if players.get_vehicle_model(player_id) == oppressor2 then
                    if mk2_ban_evaders[player_id] == nil then
                        mk2_ban_evaders[player_id] = util.current_time_millis()
                    elseif util.current_time_millis() - mk2_ban_evaders[player_id] >= 2000 and mk2_ban_warnings[player_id] == nil then
                        util.toast(players.get_name(player_id) .. " is still on a Mk II. Sending them a warning.")
                        Ryan.Player.Get(player_id).send_sms("WARNING: Get off of your Mk II or you will be kicked!")
                        mk2_ban_warnings[player_id] = true
                    elseif util.current_time_millis() - mk2_ban_evaders[player_id] >= 10000 then
                        util.toast("Kicking " .. players.get_name(player_id) .. " for not getting off their Mk II.")
                        Ryan.Player.Get(player_id).kick()
                        mk2_ban_evaders[player_id] = nil
                        mk2_ban_warnings[player_id] = nil
                    end
                else
                    mk2_ban_evaders[player_id] = nil
                    mk2_ban_warnings[player_id] = nil
                end
            end
            break
        case "Chaos":
            if util.current_time_millis() - mk2_chaos_notice >= 300000 then
                mk2_chaos_notice = util.current_time_millis()
                Ryan.Basics.SendChatMessage("This session is in Mk II Chaos mode! Type \"!mk2\" in chat at any time to get one. Good luck.")
                
                local oppressor2 = util.joaat("oppressor2")
                Ryan.Basics.RequestModel(oppressor2)

                for _, player_id in pairs(players.list()) do
                    local player = Ryan.Player.Get(player_id)
                    local coords = Ryan.Vector.Add(ENTITY.GET_ENTITY_COORDS(player.ped_id), {x = 0.0, y = 5.0, z = 0.0})
                    local vehicle = entities.create_vehicle(oppressor2, coords, ENTITY.GET_ENTITY_HEADING(player.ped_id))
                    Ryan.Entity.RequestControl(vehicle, true)
                    Ryan.Vehicle.SetFullyUpgraded(vehicle, true)
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
                    VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, true)
                    VEHICLE.SET_VEHICLE_DOOR_LATCHED(vehicle, 0, false, false, true)
                end

                Ryan.Basics.FreeModel(oppressor2)
            end
            break
    end
end)


-- Stats Menu --
menu.divider(stats_root, "Player")
stats_kd_root = menu.list(stats_root, "Kills/Deaths...", {"ryankd"}, "Controls your kills and deaths.")

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
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Stats", "Your kill count has been changed to " .. value .. "!")
        else
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Red, "Stats", "The kill count you provided was not a valid number.")
        end
        create_kd_inputs()
    end)

    stats_deaths = menu.text_input(stats_kd_root, "Deaths: -", {"ryandeaths"}, "The amount of deaths you have received.", function(value)
        value = tonumber(value)
        if value ~= nil then
            Ryan.Stats.SetDeaths(math.floor(value))
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Stats", "Your death count has been changed to " .. value .. "!")
        else
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Red, "Stats", "The death count you provided was not a valid number.")
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
chat_languages = {"No"}; for i = 1, #Ryan.Globals.Languages do table.insert(chat_languages, Ryan.Globals.Languages[i][1]) end
chat_symbols = {{"None", ""}, {"R* Logo", "∑"}, {"R* Verified", "¦"}, {"Padlock", "Ω"}}

chat_prefix = ""
chat_message = ""

function chat_preview(symbol)
    local preview = symbol .. (if symbol:len() > 0 and chat_message:len() > 0 then " " else "") .. chat_message
    util.show_corner_help("<b>Preview:</b>\n" .. (if preview:len() > 0 then preview else "\n"))
end

Ryan.UI.CreateList(chat_new_message_root, "Translate", "ryanchattranslate", "Translate the message into another language.", chat_languages, function(value)
    chat_translate = value
end)
chat_add_symbol_root = menu.list(chat_new_message_root, "Add Symbol: None", {"ryanchatsymbol"}, "Add a symbol to the message.")
for _, symbol in pairs(chat_symbols) do
    local action = menu.action(chat_add_symbol_root, symbol[1], {"ryanchat" .. Ryan.Basics.CommandName(symbol[1])}, "", function()
        chat_prefix = if symbol[2]:len() > 0 then (symbol[2] .. " ") else ""
        menu.set_menu_name(chat_add_symbol_root, "Add Symbol: " .. symbol[1])
        menu.focus(chat_add_symbol_root)
    end)
    menu.on_focus(action, function() chat_preview(symbol[2]) end)
end

menu.divider(chat_new_message_root, "Go")
menu.text_input(chat_new_message_root, "Message", {"ryanchatmessage"}, "The message to send in chat.", function(value)
    chat_message = value
end)
chat_send = menu.action(chat_new_message_root, "Send", {"ryanchatsend"}, "Send the message.", function()
    if chat_translate == "No" then
        Ryan.Basics.SendChatMessage(chat_prefix .. chat_message)
    else
        for _, language in pairs(Ryan.Globals.Languages) do
            if language[1] == chat_translate then
                Ryan.Basics.Translate(chat_message, language[2], language[3], function(result)
                    Ryan.Basics.SendChatMessage(chat_prefix .. message)
                end)
            end
        end
    end
end)
menu.on_tick_in_viewport(chat_send, function() chat_preview(chat_prefix) end)


enable_commands = false
crash_money_beggars = false
crash_car_meeters = false

menu.divider(chat_root, "Chat Options")
menu.toggle(chat_root, "Enable Commands", {"ryancommands"}, "Enables commands for all players. Use !help for a list.", function(value)
    enable_commands = value
end)
menu.toggle(chat_root, "Crash Money Beggars", {"ryancrashbeggars"}, "Crashes anyone who begs for money.", function(value)
    crash_money_beggars = value
end)
menu.toggle(chat_root, "Crash Car Meeters", {"ryancrashcarmeets"}, "Crashes anyone who suggests a car meet.", function(value)
    crash_car_meeters = value
end)

chat_commands = {
    {"help", {}, "List all commands.", nil},
    {"nuke", {}, "Drop a nuke.", "ryannukestart", nil},
    {"crash", {"player"}, "Crash their game.", "ryancrash{1}"},
    {"tank", {"player"}, "Drop a tank on them.", "ryanfallingtank{1}"},
    {"carslow", {"player"}, "Make their car slow.", "ryanspeedslow{1} on"},
    {"carlock", {"player"}, "Lock their car.", "ryandoorslock{1} on"},
    {"cardelete", {"player"}, "Delete their car.", "ryandelete{1} on"},
    {"mk2", {}, "Spawn an Oppressor Mk II.", nil}
}
chat_history = {}
chat_index = 1

function reply(message) Ryan.Basics.SendChatMessage("∑ " .. message .. " ∑") end
chat.on_message(function(packet_sender, sender, message, is_team_chat)
    local message_lower = message:lower()
    local sender_name = players.get_name(sender)
    if crash_money_beggars then
        if (message_lower:find("can") or message_lower:find("?") or message_lower:find("please") or message_lower:find("plz") or message_lower:find("pls") or message_lower:find("drop"))
        and message_lower:find("money") then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Crash Money Beggars", players.get_name(sender) .. " is being crashed for begging for money drops.")
            Ryan.Player.Get(sender).crash()
        end
    end
    if crash_car_meeters then
        if (message_lower:find("want to") or message_lower:find("wanna") or message_lower:find("at") or message_lower:find("is") or message_lower:find("?"))
        and message_lower:find("car") and message_lower:find("meet") then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Crash Car Meeters", players.get_name(sender) .. " is being crashed for suggesting a car meet.")
            Ryan.Player.Get(sender).crash()
        end
    end

    if ((mk2_chaos and message_lower:sub(1, 4) == "!mk2") or enable_commands) and message_lower:sub(1, 1) == "!" then
        local command_found = false
        for _, command in pairs(chat_commands) do
            if message_lower:sub(1, command[1]:len() + 1) == "!" .. command[1] then
                command_found = true
                
                -- Split Arguments
                local args = {}
                for arg in message:sub(command[1]:len() + 2):gmatch("%S+") do table.insert(args, arg) end

                local usage = ""
                for _, arg in pairs(command[2]) do usage = usage .. " [" .. arg .. "]" end

                if #args < #command[2] then
                    reply("Usage: !" .. command[1] .. usage)
                else
                    -- Parse Arguments
                    local has_error = false
                    for i, arg_type in pairs(command[2]) do
                        if arg_type == "player" then
                            local player = Ryan.Player.ByName(args[i])
                            if player == nil then
                                reply("Player '" .. args[i] .. "' could not be found.")
                                has_error = true
                            else
                                args[i] = player.id
                            end
                        end
                    end

                    -- Handle Command
                    if not has_error then
                        pluto_switch command[1] do
                            case "help":
                                local cmd_list = ""
                                for i, cmd in ipairs(chat_commands) do
                                    if i > 1 then
                                        local cmd_args = ""
                                        local cmd_is_specific = #args > 0 and cmd[1] == args[1]
                                        for _, arg in pairs(cmd[2]) do cmd_args = cmd_args .. " [" .. arg .. "]" end
                                        if #args == 0 or cmd_is_specific then
                                            cmd_list = cmd_list .. "!" .. cmd[1] .. cmd_args .. (if cmd_is_specific then ": " .. cmd[3] else "") .. ", "
                                        end
                                    end 
                                end
                                
                                if cmd_list:len() > 0 then reply(cmd_list:sub(1, cmd_list:len() - 2))
                                else reply("Unknown command. Use !help for a list of them.") end
                                break
                            case "mk2":
                                local oppressor2 = util.joaat("oppressor2")
                                Ryan.Basics.RequestModel(oppressor2)

                                local player = Ryan.Player.Get(sender)
                                local coords = Ryan.Vector.Add(ENTITY.GET_ENTITY_COORDS(player.ped_id), {x = 0.0, y = 5.0, z = 0.0})
                                local vehicle = entities.create_vehicle(oppressor2, coords, ENTITY.GET_ENTITY_HEADING(player.ped_id))
                                Ryan.Entity.RequestControl(vehicle, true)
                                Ryan.Vehicle.SetFullyUpgraded(vehicle, true)
                                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
                                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, true)
                                VEHICLE.SET_VEHICLE_DOOR_LATCHED(vehicle, 0, false, false, true)

                                Ryan.Basics.FreeModel(oppressor2)
                                break
                            pluto_default:
                                local raw_command = command[4]
                                for i, arg_type in pairs(command[2]) do
                                    if arg_type == "player" then raw_command = raw_command:gsub("{" .. i .. "}", players.get_name(args[i])) end
                                end

                                menu.trigger_commands(raw_command)
                                reply("Successfully executed command!")
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
            util.toast("Translating...")
            Ryan.Basics.Translate(message, "EN", false, function(result)
                Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "Translation", result)
            end)
        end)
    )
    chat_index = chat_index + 1
end)


-- Settings Menu --
menu.divider(settings_root, "Updates")
menu.action(settings_root, "Version: " .. VERSION, {}, "The currently installed version.", function() end)
menu.action(settings_root, "Reinstall", {"ryanreinstall"}, "Force update the script for patches and troubleshooting.", function() Ryan.Basics.DoUpdate(true) end)
menu.hyperlink(settings_root, "Website", "https://gta.ryanmade.site/", "Opens the official website, for downloading the installer and viewing the changelog.")

menu.divider(settings_root, "HUD")
hud_color = menu.colour(settings_root, "Color", {"ryanhudcolor"}, "The color of on-screen ESP.", 0.29, 0.69, 1.0, 1.0, false, function(value)
    Ryan.Globals.HUDColor.r = value.r
    Ryan.Globals.HUDColor.g = value.g
    Ryan.Globals.HUDColor.b = value.b
end)
hud_use_beacons = menu.toggle(settings_root, "Use Beacons", {"ryanhudbeacons"}, "Use AR Beacons instead of ESP.", function(value)
    Ryan.Globals.HUDUseBeacon = value
end)

hud_preview = 0
menu.on_focus(hud_color, function() hud_preview = hud_preview + 1 end)
menu.on_focus(hud_use_beacons, function() hud_preview = hud_preview + 1 end)
menu.on_blur(hud_color, function() hud_preview = hud_preview - 1 end)
menu.on_blur(hud_use_beacons, function() hud_preview = hud_preview - 1 end)

util.create_tick_handler(function()
    if hud_preview > 0 then
        if Ryan.Globals.HUDUseBeacon then Ryan.Basics.DrawBeacon(ENTITY.GET_ENTITY_COORDS(players.user_ped()))
        else Ryan.Entity.DrawESP(players.user_ped()) end
    end
end)

-- Player Options --
ptfx_attack = {}
money_drop = {}
remove_godmode = {}
entities_message = {}

vehicle_effects = {}
vehicle_state = {}

attach_vehicle_bones = {}
attach_vehicle_id = {}
attach_notice = {}
attach_vehicle_offset = {}
attach_root = {}

glitch = {}
glitch_state = {}
glitch_type_names = {"Off", "Default", "Ferris Wheel", "UFO", "Cement Mixer", "Scaffolding", "Garage Door", "Big Orange Ball", "Stunt Ramp"}
glitch_type_hashes = {"Off", "Default", "prop_ld_ferris_wheel", "p_spinning_anus_s", "prop_staticmixer_01", "des_scaffolding_root", "prop_sm1_11_garaged", "prop_juicestand", "stt_prop_stunt_jump_l"}


function setup_player(player_id)
    local player_root = menu.player_root(player_id)
    menu.divider(player_root, "Ryan's Menu")

    local player_name = players.get_name(player_id)
    local player_trolling_root = menu.list(player_root, "Trolling...", {"ryantrolling"}, "Options that players may not like.")
    local player_removal_root = menu.list(player_root, "Removal...", {"ryanremoval"}, "Options to remove the player forcibly.")

    
    -- Trolling --
    -- -- Kill
    local player_trolling_kill_root = menu.list(player_trolling_root, "Kill...", {"ryankill"}, "Options to kill players while they're in godmode.")
    
    menu.toggle(player_trolling_kill_root, "Remove Godmode", {"ryankillgodmode"}, "Remove godmode from players using Kiddions or inside a building.", function(value)
        remove_godmode[player_id] = if value then true else nil
    end)

    menu.toggle_loop(player_trolling_kill_root, "Kill (Kiddions)", {"ryankillstungun"}, "Use this to kill players using Kiddions godmode. May also work in some buildings.", function()
        local player = Ryan.Player.Get(player_id)
        local stun_gun = util.joaat("weapon_stungun")
        local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)
		WEAPON.REQUEST_WEAPON_ASSET(stun_gun)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), stun_gun, 1, false, true)
        player.remove_godmode()
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z + 1, coords.x, coords.y, coords.z, 1000, true, stun_gun, 0, false, true, 1.0)
    end)

    menu.toggle_loop(player_trolling_kill_root, "Kill (Interior)", {"ryankillsnowball"}, "Use this to kill players inside buildings. May also work on some menus' godmodes.", function()
        local player = Ryan.Player.Get(player_id)
		local snowball = util.joaat("weapon_snowball")
        local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)
		WEAPON.REQUEST_WEAPON_ASSET(snowball)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), snowball, 10, false, true)
        player.remove_godmode()
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 2, 200, 0, snowball, 0, true, false, 2500.0)
    end)

    menu.action(player_trolling_kill_root, "Kill (Paid Menu)", {"ryankillphysics"}, "Use this when removing godmode does not work.", function()
        Ryan.Player.Get(player_id).squish()
    end)


    -- -- Spawn
    local player_trolling_spawn_root = menu.list(player_trolling_root, "Spawn...", {"ryanspawn"}, "Entity trolling options.")
    
    Ryan.Trolling.CreateNASAMenu(player_trolling_spawn_root, player_id)
    menu.action(player_trolling_spawn_root, "Military Squad", {"ryanmilitarysquad"}, "Send an entire fucking military squad.", function()
		Ryan.Trolling.MilitarySquad(player_id, true)
    end)
    menu.action(player_trolling_spawn_root, "SWAT Raid", {"ryanswatraid"}, "Sends a SWAT team to kill them, brutally.", function()
        Ryan.Trolling.SWATTeam(player_id)
    end)
    menu.action(player_trolling_spawn_root, "Flying Yacht", {"ryanflyingyacht"}, "Send the magic school yacht to fuck their shit up.", function()
        Ryan.Trolling.FlyingYacht(player_id)
    end)
    menu.action(player_trolling_spawn_root, "Falling Tank", {"ryanfallingtank"}, "Send a tank straight from heaven.", function()
		Ryan.Trolling.FallingTank(player_id)
    end)

    menu.divider(player_trolling_spawn_root, "Options")
    menu.action(player_trolling_spawn_root, "Delete All", {"ryanentitiesdelete"}, "Deletes all previously spawned entities.", function()
        Ryan.Trolling.DeleteEntities(player_id)
    end)

    -- -- Attach
    attach_root[player_id] = menu.list(player_trolling_root, "Attach...", {"ryanattach"}, "Attaches to their vehicle on a specific bone.")
    attach_vehicle_offset[player_id] = 0.0
    attach_notice[player_id] = nil
    attach_vehicle_bones[player_id] = {}

    menu.action(attach_root[player_id], "Detach", {"ryandetach"}, "Detaches from anything you're attached to.", function()
        ENTITY.DETACH_ENTITY(players.user_ped(), false, false)
        util.toast("Detached from all entities.")
    end)
    menu.slider(attach_root[player_id], "Offset", {"ryanattachoffset"}, "Offset of the Z coordinate.", -25, 25, 1, 0, function(value)
        attach_vehicle_offset[player_id] = value
    end)


    menu.divider(attach_root[player_id], "Attach To")
    menu.action(attach_root[player_id], "Player", {"ryanattachplayer"}, "Attach to the player.", function()
        if player_id == players.user() then
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Red, "Attach", "You just almost crashed yourself. Good job!")
            return
        end

        ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), Ryan.Player.Get(player_id).ped_id, 0, 0.0, -0.2, (attach_vehicle_offset[player_id] * 0.2), 1.0, 1.0, 1, true, true, true, false, 0, true)
        util.toast("Attached to " .. players.get_name(player_id) .. ".")
    end)

    -- -- Vehicle
    local player_vehicle_root = menu.list(player_trolling_root, "Vehicle...", {"ryanvehicle"}, "Vehicle trolling options.")    

    vehicle_effects[player_id] = {}
    Ryan.UI.CreateVehicleEffectList(player_vehicle_root, "ryan", players.get_name(player_id), vehicle_effects[player_id], true, false)

    menu.toggle(player_vehicle_root, "Leash", {"ryanleash"}, "Brings their vehicle with you like a leash.", function(value)
        vehicle_effects[player_id].leash = if value then true else nil
    end)

    -- -- Glitch
    local player_trolling_glitch_root = Ryan.UI.CreateList(player_trolling_root, "Glitch", "ryanglitch", "Glitch the player and their vehicle.", glitch_type_names, function(value)
        for i = 1, #glitch_type_names do
            if glitch_type_names[i] == value then
                glitch[player_id] = glitch_type_hashes[i]
            end
        end
    end)

    -- -- Miscellaneous
    menu.toggle(player_trolling_root, "Fake Money Drop", {"ryanfakemoney"}, "Drops fake money bags on the player.", function(value)
        money_drop[player_id] = if value then true else nil
    end)
    menu.toggle_loop(player_trolling_root, "Turn Into Animal", {"ryananimal"}, "Turns the player into a random animal.", function()
        Ryan.Player.Get(player_id).turn_into_animal()
        util.yield(250)
    end)
    menu.action(player_trolling_root, "Steal Vehicle", {"ryansteal"}, "Steals the player's car.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.Get(player_id).ped_id)
        if vehicle ~= 0 then Ryan.Vehicle.Steal(vehicle)
        else Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Red, "Steal Vehicle", players.get_name(player_id) .. " is not in a vehicle.") end
    end)


    -- Removal --
    local removal_block_joins = false
    local removal_message = ""
    
    menu.text_input(player_removal_root, "Spam Message", {"ryanremovalspam"}, "The message to spam before removing the player.", function(value)
        removal_message = value
    end, removal_message)
    menu.toggle(player_removal_root, "Block Joins", {"ryanremovalblockjoins"}, "Block joins by this player.", function(value)
        removal_block_joins = value
    end)


    menu.divider(player_removal_root, "Go")
    menu.action(player_removal_root, "Stand Kick", {"ryankick"}, "Use the best possible kick method.", function()
        local player = Ryan.Player.Get(player_id)
        player.spam_sms_and_block_joins(removal_block_joins, removal_message, function()
            player.kick()
        end)
    end)
    menu.action(player_removal_root, "Stand Crash", {"ryancrash"}, "Use the best possible crash methods.", function()
        local player = Ryan.Player.Get(player_id)
        player.spam_sms_and_block_joins(removal_block_joins, removal_message, function()
            player.crash()
        end)
    end)
    menu.action(player_removal_root, "Super Crash", {"ryansuper"}, "A crash that should work on 2take1 and Cherax.", function()
        local player = Ryan.Player.Get(player_id)
        player.spam_sms_and_block_joins(removal_block_joins, removal_message, function()
            player.super_crash(true)
        end)
    end)


    -- Divorce Kick --
    menu.action(player_root, "Divorce", {"ryandivorce"}, "Kicks the player, then blocks future joins by them.", function()
        menu.trigger_commands("historyblock" .. players.get_name(player_id))
        Ryan.Player.Get(player_id).kick()
        menu.trigger_commands("players")
    end)
end

util.create_tick_handler(function()
    for _, player in pairs(Ryan.Player.List(true, true, true)) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player.ped_id, true)
        if vehicle ~= 0 and vehicle_effects[player.id] ~= nil then
            Ryan.UI.ApplyVehicleEffectList(vehicle, vehicle_effects[player.id], vehicle_state, true, false)

            -- Leash
            if vehicle_effects[player.id].leash == true then
                local player_coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
                if Ryan.Vector.Distance(vehicle_coords, player_coords) > 5 then
                    local force = Ryan.Vector.Normalize(Ryan.Vector.Subtract(player_coords, vehicle_coords))
                    Ryan.Entity.RequestControl(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, force.x * 5, force.y * 5, force.z * 5, 0, 0, 0.5, 0, false, false, true)
                else
                    ENTITY.SET_ENTITY_VELOCITY(vehicle, 0, 0, 0)
                end
            end
        end
    end
    util.yield(250)
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
    for _, player_id in pairs(players.list()) do
        if attach_root[player_id] ~= nil then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.Get(player_id).ped_id, true)
            if vehicle ~= attach_vehicle_id[player_id] then
                for _, bone in pairs(attach_vehicle_bones[player_id]) do menu.delete(bone) end
                attach_vehicle_bones[player_id] = {}

                for i = 1, #Ryan.Globals.VehicleAttachBones do
                    local bone = if Ryan.Globals.VehicleAttachBones[i][2] ~= nil then ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, Ryan.Globals.VehicleAttachBones[i][2]) else 0

                    if bone ~= -1 then
                        table.insert(
                            attach_vehicle_bones[player_id],
                            menu.action(attach_root[player_id], Ryan.Globals.VehicleAttachBones[i][1], {"ryanattach" .. Ryan.Globals.VehicleAttachBones[i][1]}, "Attaches to the bone.", function()
                                local vehicle = PED.GET_VEHICLE_PED_IS_IN(Ryan.Player.Get(player_id).ped_id, true)
                                ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), vehicle, bone, 0.0, -0.2, (if bone == 0 then 2.0 else 1.0) + (attach_vehicle_offset[player_id] * 0.2), 1.0, 1.0, 1, true, true, true, false, 0, true)
                                util.toast("Attached to " .. players.get_name(player_id) .. "'s vehicle.")
                            end)
                        )
                    end
                end
            elseif vehicle == 0 then
                for _, bone in pairs(attach_vehicle_bones[player_id]) do menu.delete(bone) end
                attach_vehicle_bones[player_id] = {}
            end

            attach_vehicle_id[player_id] = vehicle
        end
    end
    util.yield(500)
end)

util.create_tick_handler(function()
    for _, player_id in pairs(players.list()) do
        if remove_godmode[player_id] == true then
            Ryan.Player.Get(player_id).remove_godmode()
        end
        if glitch_state[player_id] ~= glitch[player_id] then
            util.create_thread(function()
                local glitch_type = glitch[player_id]
                while glitch[player_id] == glitch_type do
                    pluto_switch glitch_type do
                        case "Off":
                            break
                        case "Default":
                            local shuttering = util.joaat("prop_shuttering03")
                            Ryan.Basics.RequestModel(shuttering)

                            local player = Ryan.Player.Get(player_id)
                            local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id, false)
                            
                            local objects = {
                                entities.create_object(shuttering, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.ped_id, 0, 1, 0)),
                                entities.create_object(shuttering, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.ped_id, 0, 0, 0))
                            }

                            ENTITY.SET_ENTITY_VISIBLE(objects[1], false)
                            ENTITY.SET_ENTITY_VISIBLE(objects[2], false)
                            util.yield()
                            entities.delete_by_handle(objects[1])
                            entities.delete_by_handle(objects[2])

                            Ryan.Basics.FreeModel(shuttering)
                            break
                        pluto_default:
                            local glitch_object, rallytruck = util.joaat(glitch[player_id]), util.joaat("rallytruck")
                            Ryan.Basics.RequestModel(glitch_object)
                            Ryan.Basics.RequestModel(rallytruck)

                            local player_coords = ENTITY.GET_ENTITY_COORDS(Ryan.Player.Get(player_id).ped_id, false)

                            local objects = {
                                entities.create_object(glitch_object, player_coords),
                                entities.create_vehicle(rallytruck, player_coords, 0)
                            }

                            ENTITY.SET_ENTITY_VISIBLE(objects[1], false)
                            ENTITY.SET_ENTITY_VISIBLE(objects[2], false)
                            ENTITY.SET_ENTITY_INVINCIBLE(objects[1], true)
                            ENTITY.SET_ENTITY_COLLISION(objects[1], true, true)
                            ENTITY.APPLY_FORCE_TO_ENTITY(objects[2], 1, 0.0, 10, 10, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)

                            util.yield(50)
                            entities.delete_by_handle(objects[1])
                            entities.delete_by_handle(objects[2])

                            util.yield(49)
                            Ryan.Basics.FreeModel(glitch_object)
                            Ryan.Basics.FreeModel(rallytruck)
                    end
                    util.yield()
                end
                return false
            end)
            glitch_state[player_id] = glitch[player_id]
        end
    end
end)

function cleanup_player(player_id)
    money_drop[player_id] = nil
    ptfx_attack[player_id] = nil
    remove_godmode[player_id] = nil
    entities_message[player_id] = nil
    
    vehicle_effects[player_id] = nil

    attach_vehicle_bones[player_id] = nil
    attach_vehicle_id[player_id] = nil
    attach_notice[player_id] = nil
    attach_vehicle_offset[player_id] = nil
    attach_root[player_id] = nil

    glitch[player_id] = nil
    glitch_state[player_id] = nil

    hermits[player_id] = nil
    hermit_list[player_id] = nil

    Ryan.Trolling.DeleteEntities(player_id)
end


-- Initialize --
players.on_join(function(player_id) setup_player(player_id) end)
players.on_leave(function(player_id) cleanup_player(player_id) end)
players.dispatch_on_join()

util.keep_running()

while true do
    if crosshair or god_finger_active then
        local weapon = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
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