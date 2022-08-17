VERSION = "0.10.5"
MANIFEST = {
    lib = {"Core.lua", "JSON.lua", "Natives.lua", "Objects.lua", "Player.lua", "PTFX.lua", "Trolling.lua", "UI.lua"},
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
            if required_file == "Core.lua" or required_file == "Natives.lua" or required_file == "JSON.lua" then
                while not exists(required_directory .. "\\" .. SUBFOLDER_NAME .. "\\" .. required_file) do
                    Ryan.Toast("Ryan's Menu is missing a required file and must be reinstalled.")
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

Ryan.DoUpdate(false)

Ryan.Init()
util.create_tick_handler(Ryan.OnTick)


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

PTFX.CreateList(self_ptfx_body_head_root, function(ptfx)
    if ptfx_disable then return end
    PTFX.PlayOnEntityBones(players.user_ped(), PTFX.PlayerBones.Head, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

PTFX.CreateList(self_ptfx_body_hands_root, function(ptfx)
    if ptfx_disable then return end
    PTFX.PlayOnEntityBones(players.user_ped(), PTFX.PlayerBones.Hands, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)


PTFX.CreateList(self_ptfx_body_feet_root, function(ptfx)
    if ptfx_disable then return end
    PTFX.PlayOnEntityBones(players.user_ped(), PTFX.PlayerBones.Feet, ptfx[2], ptfx[3], ptfx_color)
    util.yield(ptfx[4])
end)

PTFX.CreateList(self_ptfx_body_pointer_root, function(ptfx)
    if ptfx_disable then return end
    if PlayerIsPointing then
        PTFX.PlayOnEntityBones(players.user_ped(), PTFX.PlayerBones.Pointer, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Vehicle PTFX
self_ptfx_vehicle_wheels_root = menu.list(self_ptfx_vehicle_root, "Wheels...", {"ryanptfxwheels"}, "Special FX on the wheels of your vehicle.")
self_ptfx_vehicle_exhaust_root = menu.list(self_ptfx_vehicle_root, "Exhaust...", {"ryanptfxexhaust"}, "Speicla FX on the exhaust of your vehicle.")

PTFX.CreateList(self_ptfx_vehicle_wheels_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true)
    if vehicle ~= 0 then
        PTFX.PlayOnEntityBones(vehicle, PTFX.VehicleBones.Wheels, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

PTFX.CreateList(self_ptfx_vehicle_exhaust_root, function(ptfx)
    if ptfx_disable then return end
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true)
    if vehicle ~= 0 then
        PTFX.PlayOnEntityBones(vehicle, PTFX.VehicleBones.Exhaust, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

-- -- Weapon PTFX
self_ptfx_weapon_aiming_root = menu.list(self_ptfx_weapon_root, "Crosshair...", {"ryanptfxcrosshair"}, "Special FX when aiming at a spot.")
self_ptfx_weapon_muzzle_root = menu.list(self_ptfx_weapon_root, "Muzzle...", {"ryanptfxmuzzle"}, "Special FX on the end of your weapon's barrel.")
self_ptfx_weapon_muzzle_flash_root = menu.list(self_ptfx_weapon_root, "Muzzle Flash...", {"ryanptfxmuzzleflash"}, "Special FX on the end of your weapon's barrel when firing.")
self_ptfx_weapon_impact_root = menu.list(self_ptfx_weapon_root, "Impact...", {"ryanptfximpact"}, "Special FX at the impact of your bullets.")

PTFX.CreateList(self_ptfx_weapon_aiming_root, function(ptfx)
    if ptfx_disable then return end
    if CAM.IS_AIM_CAM_ACTIVE() then
        local raycast = Ryan.RaycastFromCamera(500.0, Ryan.RaycastFlags.All)
        if raycast.did_hit then
            PTFX.PlayAtCoords(raycast.hit_coords, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

PTFX.CreateList(self_ptfx_weapon_muzzle_root, function(ptfx)
    if ptfx_disable then return end
    local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped())
    if weapon ~= NULL then
        PTFX.PlayAtEntityBoneCoords(weapon, PTFX.WeaponBones.Muzzle, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)

PTFX.CreateList(self_ptfx_weapon_muzzle_flash_root, function(ptfx)
    if ptfx_disable then return end
    local our_ped = players.user_ped()
    if PED.IS_PED_SHOOTING(our_ped) then
        local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(our_ped)
        if weapon ~= NULL then
            PTFX.PlayAtEntityBoneCoords(weapon, PTFX.WeaponBones.Muzzle, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

PTFX.CreateList(self_ptfx_weapon_impact_root, function(ptfx)
    if ptfx_disable then return end
    local impact = v3.new()
    if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), impact) then
        PTFX.PlayAtCoords(impact, ptfx[2], ptfx[3], ptfx_color)
    end
end)

-- -- God Finger PTFX
self_ptfx_god_finger_crosshair_root = menu.list(self_ptfx_god_finger_root, "Crosshair...", {"ryanptfxgodfingercrosshair"}, "Special FX wherever you point when using God Finger.")
self_ptfx_god_finger_entities_root = menu.list(self_ptfx_god_finger_root, "Entities...", {"ryanptfxgodfingerentities"}, "Special FX only on entities when using God Finger.")

PTFX.CreateList(self_ptfx_god_finger_crosshair_root, function(ptfx)
    if ptfx_disable then return end
    if god_finger_active then
        local raycast = Ryan.RaycastFromCamera(1000.0, Ryan.RaycastFlags.All)
        if raycast.did_hit then
            PTFX.PlayAtCoords(raycast.hit_coords, ptfx[2], ptfx[3], ptfx_color)
            util.yield(ptfx[4])
        end
    end
end)

PTFX.CreateList(self_ptfx_god_finger_entities_root, function(ptfx)
    if ptfx_disable then return end
    if god_finger_target ~= nil then
        PTFX.PlayAtCoords(god_finger_target, ptfx[2], ptfx[3], ptfx_color)
        util.yield(ptfx[4])
    end
end)


-- -- Forcefield
forcefield_size = 10
forcefield_force = 1

UI.CreateList(self_forcefield_root, "Mode", "ryanforcefieldmode", "The type of force to apply.", Ryan.ForcefieldTypes, function(value)
    forcefield_type = value
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
        GRAPHICS._DRAW_SPHERE(coords.x, coords.y, coords.z, forcefield_size, math.floor(Ryan.HUDColor.r * 255), math.floor(Ryan.HUDColor.g * 255), math.floor(Ryan.HUDColor.b * 255), 0.3)
    end

    if forcefield_type ~= "Off" then
        local ourself = Player:Self()
        local nearby = Objects.GetAllNearCoords(ourself.get_coords(), forcefield_size, Objects.Type.All)
        for _, entity in pairs(nearby) do
            if (players.get_vehicle_model(players.user()) == 0 or entity ~= entities.get_user_vehicle_as_handle()) and entity ~= players.user_ped() then
            pluto_switch forcefield_type do
                    case "Push": -- Push entities away
                        local force = ENTITY.GET_ENTITY_COORDS(entity)
                        force:sub(ourself.get_coords()); force:normalise()
                        force:mul(forcefield_force * 0.25)
                        if ENTITY.IS_ENTITY_A_PED(entity) then
                            if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                                Objects.RequestControl(entity)
                                PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                            end
                        else
                            Objects.RequestControl(entity)
                            ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                        end
                        break
                    case "Pull": -- Pull entities in
                        local force = ENTITY.GET_ENTITY_COORDS(entity)
                        force:sub(ourself.get_coords()); force:normalise()
                        force:mul(forcefield_force * 0.25)
                        if ENTITY.IS_ENTITY_A_PED(entity) then
                            if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                                Objects.RequestControl(entity)
                                PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, -force.x, -force.y, -force.z, 0, 0, 0.5, 0, false, false, true)
                            end
                        else
                            Objects.RequestControl(entity)
                            ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, -force.x, -force.y, -force.z, 0, 0, 0.5, 0, false, false, true)
                        end
                        break
                    case "Spin": -- Spin entities around
                        if not ENTITY.IS_ENTITY_A_PED(entity) and entity ~= entities.get_user_vehicle_as_handle() then
                            Objects.RequestControl(entity)
                            ENTITY.SET_ENTITY_HEADING(entity, ENTITY.GET_ENTITY_HEADING(entity) + 2.5 * forcefield_force)
                        end
                        break
                    case "Up": -- Force entities into air
                        local force = v3(0, 0, forcefield_force * 0.5)
                        if ENTITY.IS_ENTITY_A_PED(entity) then
                            if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                                Objects.RequestControl(entity)
                                PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                            end
                        else
                            Objects.RequestControl(entity)
                            ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                        end
                        break
                    case "Down": -- Force entities into ground
                        local force = v3(0, 0, forcefield_force * -2)
                        if ENTITY.IS_ENTITY_A_PED(entity) then
                            if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                                Objects.RequestControl(entity)
                                PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                            end
                        else
                            Objects.RequestControl(entity)
                            ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                        end
                        break
                    case "Smash": -- Smash entities into ground
                        local direction = if util.current_time_millis() % 3000 >= 1250 then -2 else 0.5
                        local force = v3(0, 0, direction * forcefield_force)
                        if ENTITY.IS_ENTITY_A_PED(entity) then
                            if not PED.IS_PED_A_PLAYER(entity) and not PED.IS_PED_IN_ANY_VEHICLE(entity, true) then
                                Objects.RequestControl(entity)
                                PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                            end
                        else
                            Objects.RequestControl(entity)
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
                                    Objects.RequestControl(entity)
                                    PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, 0, 0, 0)
                                    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, false, true)
                                end
                            else
                                Objects.RequestControl(entity)
                                ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, false, true)
                            end
                            entities_chaosed[entity] = util.current_time_millis()
                        end
                        break
                    case "Explode": -- Explode entities
                        if entities_exploded[entity] == nil then
                            local coords = ENTITY.GET_ENTITY_COORDS(entity)
                            FIRE.ADD_EXPLOSION(
                                coords.x, coords.y, coords.z,
                                7, 5.0, false, true, 0.0
                            )
                            entities_exploded[entity] = true
                        end
                        break
                end
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
UI.CreateEffectToggle(self_god_finger_player_root, "ryangodfingerplayer", god_finger_player_effects, "Kick", "Kick the player.", true)
UI.CreateEffectToggle(self_god_finger_player_root, "ryangodfingerplayer", god_finger_player_effects, "Crash", "Crash the player.", true)
UI.CreateEffectToggle(self_god_finger_player_root, "ryangodfingerplayer", god_finger_player_effects, "Super Crash", "Super Crash the player.", true)

-- -- Vehicle
UI.CreateVehicleEffectList(self_god_finger_vehicle_root, "ryangodfingervehicle", "", god_finger_vehicle_effects, true, true)
UI.CreateEffectToggle(self_god_finger_vehicle_root, "ryangodfingervehicle", god_finger_vehicle_effects, "Steal", "Steal the vehicle.", true)

-- -- World
UI.CreateEffectToggle(self_god_finger_world_root, "ryangodfingerworld", god_finger_world_effects, "Nude Yoga", "Spawn a nude NPC doing yoga.", true)
UI.CreateEffectToggle(self_god_finger_world_root, "ryangodfingerworld", god_finger_world_effects, "Police Brutality", "Spawn a scene of police brutality.", true)
UI.CreateEffectToggle(self_god_finger_world_root, "ryangodfingerworld", god_finger_world_effects, "Fire", "Start a fire.", true)

-- -- NPC
UI.CreateNPCEffectList(self_god_finger_npc_root, "ryangodfingernpc", god_finger_npc_effects, true)

-- -- Force
for _, mode in pairs(Ryan.GodFingerForces) do
    UI.CreateEffectToggle(self_god_finger_force_root, "ryangodfingerforce", god_finger_force_effects, mode, "", true)
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

    ENTITY.SET_ENTITY_PROOFS(players.user_ped(), false, false, UI.GetGodFingerActivation(god_finger_force_effects.default) > 0, false, false, false, 1, false)

    god_finger_active = (god_finger_while_pointing     and PlayerIsPointing)
                     or (god_finger_while_holding_alt  and PAD.IS_DISABLED_CONTROL_PRESSED(0, Ryan.Controls.CharacterWheel))
    
    if not god_finger_active then
        god_finger_target = nil;
        return
    end

    UI.DisableGodFingerKeybinds()

    local raycast = nil
    local keybinds = {}
    memory.write_int(memory.script_global(4521801 + 935), NETWORK.GET_NETWORK_TIME())

    raycast = Ryan.RaycastFromCamera(500.0, Ryan.RaycastFlags.Vehicles + Ryan.RaycastFlags.Peds + Ryan.RaycastFlags.Objects)
    if raycast.did_hit then
        god_finger_target = raycast.hit_coords
        Objects.DrawESP(raycast.hit_entity)

        if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
            local ped = raycast.hit_entity
            --Ryan.Toast("NPC: " .. ENTITY.GET_ENTITY_MODEL(raycast.hit_entity))

            if PED.IS_PED_A_PLAYER(ped) then
                -- Player
                local keybinds_player = UI.GetGodFingerKeybinds(god_finger_player_effects)
                if keybinds_player:len() > 0 then keybinds["Player"] = keybinds_player end

                local player_id = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)
                if UI.GetGodFingerActivation(god_finger_player_effects.kick) > 0 then
                    if util.current_time_millis() - god_finger_player_state.kick > 1000 then
                        god_finger_player_state.kick = util.current_time_millis()
                        Player:Get(player_id):kick()
                        Ryan.PlaySelectSound()
                    end
                end
                if UI.GetGodFingerActivation(god_finger_player_effects.crash) > 0 then
                    if util.current_time_millis() - god_finger_player_state.crash > 1000 then
                        god_finger_player_state.crash = util.current_time_millis()
                        Player:Get(player_id):crash()
                        Ryan.PlaySelectSound()
                    end
                end
                if UI.GetGodFingerActivation(god_finger_player_effects.super_crash) > 0 then
                    if util.current_time_millis() - god_finger_player_state.super_crash > 1000 then
                        god_finger_player_state.super_crash = util.current_time_millis()
                        Player:Get(player_id):super_crash(true)
                        Ryan.PlaySelectSound()
                    end
                end
            else
                -- NPC
                local keybinds_npc = UI.GetGodFingerKeybinds(god_finger_npc_effects)
                if keybinds_npc:len() > 0 then keybinds["NPC"] = keybinds_npc end

                UI.ApplyNPCEffectList(ped, god_finger_npc_effects, god_finger_npc_state, true)
            end
        end

        if ENTITY.IS_ENTITY_A_VEHICLE(raycast.hit_entity) then
            -- Vehicle
            local keybinds_vehicle = UI.GetGodFingerKeybinds(god_finger_vehicle_effects)
            if keybinds_vehicle:len() > 0 then keybinds["Vehicle"] = keybinds_vehicle end

            local vehicle = raycast.hit_entity
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            --Ryan.Toast("Driver: " .. (if driver ~= 0 then ENTITY.GET_ENTITY_MODEL(driver) else "none"))
    
            UI.ApplyVehicleEffectList(vehicle, god_finger_vehicle_effects, god_finger_vehicle_state, PED.IS_PED_A_PLAYER(driver), true)
            if UI.GetGodFingerActivation(god_finger_vehicle_effects.steal) > 0 and ENTITY.IS_ENTITY_A_VEHICLE(raycast.hit_entity) then
                if util.current_time_millis() - god_finger_vehicle_state.steal > 1000 then
                    god_finger_vehicle_state.steal = util.current_time_millis()
                    Objects.StealVehicle(raycast.hit_entity)
                    Ryan.PlaySelectSound()
                end
            end
        end

        -- Force
        local keybinds_force = UI.GetGodFingerKeybinds(god_finger_force_effects)
        if keybinds_force:len() > 0 then keybinds["Force"] = keybinds_force end

        local forces = {
            ["default"] = UI.GetGodFingerActivation(god_finger_force_effects.default) > 0,
            ["push"] = UI.GetGodFingerActivation(god_finger_force_effects.push) > 0,
            ["pull"] = UI.GetGodFingerActivation(god_finger_force_effects.pull) > 0,
            ["spin"] = UI.GetGodFingerActivation(god_finger_force_effects.spin) > 0,
            ["up"] = UI.GetGodFingerActivation(god_finger_force_effects.up) > 0,
            ["down"] = UI.GetGodFingerActivation(god_finger_force_effects.down) > 0,
            ["smash"] = UI.GetGodFingerActivation(god_finger_force_effects.smash) > 0,
            ["chaos"] = UI.GetGodFingerActivation(god_finger_force_effects.chaos) > 0,
            ["explode"] = UI.GetGodFingerActivation(god_finger_force_effects.explode) > 0
        }
        for key, _ in pairs(forces) do Ryan.ToggleSelectSound(forces, god_finger_force_state, key) end

        if forces.default then
            FIRE.ADD_EXPLOSION(raycast.hit_coords.x, raycast.hit_coords.y, raycast.hit_coords.z, 29, 25.0, false, true, 0.0, true)
        elseif forces.push then -- Push entities away
            local force = ENTITY.GET_ENTITY_COORDS(raycast.hit_entity)
            force:sub(ENTITY.GET_ENTITY_COORDS(players.user_ped())); force:normalise()
            force:mul(0.4)
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Objects.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif raycast.hit_entity ~= entities.get_user_vehicle_as_handle() then
                Objects.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif forces.pull then -- Pull entities in
            local force = ENTITY.GET_ENTITY_COORDS(raycast.hit_entity)
            force:sub(ENTITY.GET_ENTITY_COORDS(players.user_ped())); force:normalise()
            force:mul(0.35)
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Objects.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, -force.x, -force.y, -force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif raycast.hit_entity ~= entities.get_user_vehicle_as_handle() then
                Objects.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, -force.x, -force.y, -force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif forces.spin then -- Spin entities around
            if not ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                Objects.RequestControl(raycast.hit_entity)
                ENTITY.SET_ENTITY_HEADING(raycast.hit_entity, ENTITY.GET_ENTITY_HEADING(raycast.hit_entity) + 2.5)
            end
        elseif forces.up then -- Force entities into air
            local force = v3(0, 0, 0.5)
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Objects.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif entity ~= entities.get_user_vehicle_as_handle() then
                Objects.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif forces.down then -- Force entities into ground
            local force = v3(0, 0, -2)
            if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                    Objects.RequestControl(raycast.hit_entity)
                    PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                    ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
                end
            elseif entity ~= entities.get_user_vehicle_as_handle() then
                Objects.RequestControl(raycast.hit_entity)
                ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0.5, 0, false, false, true)
            end
        elseif forces.smash then -- Smash entities into ground
            if entities_smashed[raycast.hit_entity] == nil or util.current_time_millis() - entities_smashed[raycast.hit_entity] > 2500 then
                Objects.RequestControl(raycast.hit_entity)
                entities_smashed[raycast.hit_entity] = util.current_time_millis()
            end
        elseif forces.chaos then -- Chaotic entities
            if entities_chaosed[raycast.hit_entity] == nil or util.current_time_millis() - entities_chaosed[raycast.hit_entity] > 1000 then
                local amount = 20
                local force = v3(
                    if math.random(0, 1) == 0 then -amount else amount,
                    if math.random(0, 1) == 0 then -amount else amount,
                    0
                )
                if ENTITY.IS_ENTITY_A_PED(raycast.hit_entity) then
                    if not PED.IS_PED_A_PLAYER(raycast.hit_entity) and not PED.IS_PED_IN_ANY_VEHICLE(raycast.hit_entity, true) then
                        Objects.RequestControl(raycast.hit_entity)
                        PED.SET_PED_TO_RAGDOLL(raycast.hit_entity, 1000, 1000, 0, 0, 0, 0)
                        ENTITY.APPLY_FORCE_TO_ENTITY(raycast.hit_entity, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, false, true)
                    end
                elseif raycast.hit_entity ~= entities.get_user_vehicle_as_handle() then
                    Objects.RequestControl(raycast.hit_entity)
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

        raycast = Ryan.RaycastFromCamera(500.0, Ryan.RaycastFlags.World)
        if raycast.did_hit then
            -- World
            local keybinds_world = UI.GetGodFingerKeybinds(god_finger_world_effects)
            if keybinds_world:len() > 0 then keybinds["World"] = keybinds_world end

            if UI.GetGodFingerActivation(god_finger_world_effects.nude_yoga) > 0 then
                if util.current_time_millis() - god_finger_world_state.nude_yoga > 2000 then
                    god_finger_world_state.nude_yoga = util.current_time_millis()

                    local raycast = Ryan.RaycastFromCamera(50.0, Ryan.RaycastFlags.World)
                    if raycast.did_hit then
                        local topless, acult = util.joaat("a_f_y_topless_01"), util.joaat("a_m_y_acult_01")
                        Ryan.RequestModel(topless); Ryan.RequestAnimations("amb@world_human_yoga@female@base")
                        Ryan.RequestModel(acult); Ryan.RequestAnimations("switch@trevor@jerking_off")

                        local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())
                        local ped = entities.create_ped(0, topless, raycast.hit_coords, heading)
                        PED.SET_PED_COMPONENT_VARIATION(ped, 8, 1, -1, 0)
                        TASK.TASK_PLAY_ANIM(ped, "amb@world_human_yoga@female@base", "base_a", 8.0, 0, -1, 9, 0, false, false, false)

                        local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())
                        local coords = raycast.hit_coords; coords:add(v3(-3, 0, 0))
                        local ped = entities.create_ped(0, acult, coords, heading)
                        PED.SET_PED_COMPONENT_VARIATION(ped, 4, 0, 0, 0)
                        PED.SET_PED_COMPONENT_VARIATION(ped, 8, 0, 0, 0)
                        TASK.TASK_PLAY_ANIM(ped, "switch@trevor@jerking_off", "trev_jerking_off_loop", 8.0, 0, -1, 9, 0, false, false, false)
                        
                        Ryan.FreeModel(topless)
                        Ryan.FreeModel(acult)
                    end
                end
            end

            if UI.GetGodFingerActivation(god_finger_world_effects.police_brutality) > 0 then
                if util.current_time_millis() - god_finger_world_state.police_brutality > 2000 then
                    god_finger_world_state.police_brutality = util.current_time_millis()

                    local raycast = Ryan.RaycastFromCamera(50.0, Ryan.RaycastFlags.World)
                    if raycast.did_hit then
                        local famfor, cop = util.joaat("g_m_y_famfor_01"), util.joaat("s_f_y_cop_01")
                        Ryan.RequestModel(famfor); Ryan.RequestAnimations("missheistdockssetup1ig_13@main_action")
                        Ryan.RequestModel(cop); Ryan.RequestAnimations("move_m@intimidation@cop@unarmed")

                        local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())

                        civilians = {}
                        for i = 1, 3 do
                            local coords = raycast.hit_coords; coords:add(v3(i, math.random(-1, 1), 0))
                            local ped = entities.create_ped(0, famfor, coords, heading)
                            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, famfor)
                            PED.SET_PED_COMPONENT_VARIATION(ped, 8, 1, -1, 0)
                            animations = {"guard_beatup_mainaction_dockworker", "guard_beatup_mainaction_guard1", "guard_beatup_mainaction_guard2"}
                            TASK.TASK_PLAY_ANIM(ped, "missheistdockssetup1ig_13@main_action", animations[i], 8.0, 0, -1, 9, 0, false, false, false)
                            
                            table.insert(civilians, ped)
                        end

                        util.yield(750)

                        cops = {}
                        for i = 1, 3 do
                            local coords = raycast.hit_coords; coords:add(v3(3 + i, math.random(-1, 1), 0))
                            local ped = entities.create_ped(0, cop, coords, heading)
                            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, cop)
                            PED.SET_PED_COMPONENT_VARIATION(ped, 8, 1, -1, 0)
                            TASK.TASK_PLAY_ANIM(ped, "move_m@intimidation@cop@unarmed", "idle", 8.0, 0, -1, 9, 0, false, false, false)

                            WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_appistol"), 1000, false, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)

                            local rotation = coords:lookAt(ENTITY.GET_ENTITY_COORDS(civilians[i]))
                            ENTITY.SET_ENTITY_ROTATION(ped, rotation.x, rotation.y, rotation.z, 2, true)
                            rotation = ENTITY.GET_ENTITY_COORDS(civilians[i]):lookAt(coords)
                            ENTITY.SET_ENTITY_ROTATION(civilians[i], rotation.x, rotation.y, rotation.z, 2, true)

                            table.insert(cops, ped)
                        end

                        util.yield(750)

                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, util.joaat("g_m_y_famfor_01"), util.joaat("s_f_y_cop_01"))
                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, util.joaat("s_f_y_cop_01"), util.joaat("g_m_y_famfor_01"))
                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, util.joaat("s_f_y_cop_01"), util.joaat("s_f_y_cop_01"))
                        for i = 1, #cops do TASK.TASK_COMBAT_PED(cops[i], civilians[i], 0, 16) end

                        Ryan.FreeModel(famfor)
                        Ryan.FreeModel(cop)
                    end
                end
            end

            if UI.GetGodFingerActivation(god_finger_world_effects.fire) > 0 then
                if util.current_time_millis() - god_finger_world_state.fire > 1000 then
                    god_finger_world_state.fire = util.current_time_millis()

                    local raycast = Ryan.RaycastFromCamera(250.0, Ryan.RaycastFlags.World)
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
        Objects.AddSpotlight(our_ped, spotlight_offset, spotlight_intensity)
    end
end)

menu.action(self_spotlight_root, "Add To Vehicle", {"ryanspotlightvehicle"}, "Adds spotlights to your vehicle.", function()
    local player_id, our_ped = players.user(), players.user_ped()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= 0 then
        Objects.AddSpotlight(vehicle, spotlight_offset, spotlight_intensity)
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
    Objects.DetachAll(players.user_ped())
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= 0 then
        Objects.DetachAll(vehicle)
    end
end)

-- -- Character
ghost_mode = false
menu.toggle(self_character_root, "Ghost Mode", {"ryanghost"}, "Become entirely invisible to other players.", function(value)
    ghost_mode = value
    menu.trigger_commands("invisibility " .. (if value then "remote" else "off"))
    menu.trigger_commands("otr " .. (if value then "on" else "off"))
    if value then Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Ghost Mode", "Ghost Mode enabled. Players can no longer see you.")
    else Ryan.ShowTextMessage(Ryan.BackgroundColors.Orange, "Ghost Mode", "Ghost Mode disabled. Players can see you!") end
end)
util.create_tick_handler(function()
    if ghost_mode then util.draw_debug_text("Ghost Mode") end
end)

menu.action(self_character_root, "Become Nude", {"ryannude"}, "Make yourself a stripper with her tits out.", function()
    local topless = util.joaat("a_f_y_topless_01")
    Ryan.RequestModel(topless)

    local user = Player:Self()
    local vehicle_id = if players.get_vehicle_model(user.id) ~= 0 then PED.GET_VEHICLE_PED_IS_IN(user.ped_id, false) else 0
    local seat_id = user.get_vehicle_seat()

    local coords = ourself.get_coords(); coords:add(v3(0, 0, 5))
    if vehicle_id ~= 0 then Ryan.Teleport(coords) end
    PLAYER.SET_PLAYER_MODEL(user.id, topless)
    util.yield(250)
    PED.SET_PED_COMPONENT_VARIATION(user.ped_id, 8, 1, -1, 0)
    if vehicle_id ~= 0 then PED.SET_PED_INTO_VEHICLE(user.ped_id, vehicle_id, seat_id) end

    Ryan.FreeModel(topless)
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
                table.insert(switch_seats_actions, menu.action(self_seats_root, Ryan.SeatName(seat), {"ryanseat" .. (seat + 2)}, "Switch to " .. Ryan.SeatName(seat) .. ".", function()
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle_id, seat)
                end))
            end
        else
            for seat = -1, seats - 2 do
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle_id, seat) ~= 0 then
                    menu.set_menu_name(switch_seats_actions[seat + 2], Ryan.SeatName(seat) .. " [Taken]")
                else
                    menu.set_menu_name(switch_seats_actions[seat + 2], Ryan.SeatName(seat))
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
    if not value then Objects.SetVehicleHasGrip(vehicle, true) end
    ebrake = value
end)

util.create_tick_handler(function()
    if ebrake then
        local our_ped = players.user_ped()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(our_ped, false)
        if vehicle ~= 0 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) == our_ped then
            Objects.SetVehicleHasGrip(vehicle, not PAD.IS_CONTROL_PRESSED(0, Ryan.Controls.Sprint))
        end
    end
end)

-- -- Auto-Repair
menu.toggle_loop(self_root, "Auto-Repair", {"ryanautorepair"}, "Keeps your vehicle in mint condition for all players.", function()
    local vehicle = entities.get_user_vehicle_as_handle()

    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), Ryan.Tasks.EnterVehicle)
        or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), Ryan.Tasks.ExitVehicle)
        or not VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) then return end

    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
    VEHICLE.SET_VEHICLE_FIXED(vehicle)
end)


-- World Menu --
menu.divider(world_root, "General")
world_all_npcs_root = menu.list(world_root, "All NPCs...", {"ryanallnpcs"}, "Affects all NPCs in the world.")
world_collectibles_root = menu.list(world_root, "Collectibles...", {"ryancollectibles"}, "Useful presets to teleport to.")
world_spectate_root = menu.list(world_root, "Quick Spectate...", {"ryanspectate"}, "Easily spectate everyone in the lobby.")

-- -- All NPCs
all_npcs_include_drivers = false
all_npcs_effects = {}
all_npcs_state = {}

menu.divider(world_all_npcs_root, "Include")
menu.toggle(world_all_npcs_root, "Drivers", {"ryanallnpcsdrivers"}, "If enabled, NPCs will get out of their vehicles.", function(value)
    all_npcs_include_drivers = value
end, false)

menu.divider(world_all_npcs_root, "Effects")
UI.CreateNPCEffectList(world_all_npcs_root, "ryanallnpcs", all_npcs_effects, false)

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
        for _, ped in pairs(Objects.GetAllNearCoords(player_coords, 250, Objects.Type.Ped)) do
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            if not PED.IS_PED_A_PLAYER(ped) and (all_npcs_include_drivers or vehicle == 0) then
                if vehicle ~= 0 then
                    ENTITY.SET_ENTITY_VELOCITY(vehicle, 0.0, 0.0, 0.0)
                    TASK.TASK_EVERYONE_LEAVE_VEHICLE(vehicle)
                end

                UI.ApplyNPCEffectList(ped, all_npcs_effects, all_npcs_state, false)
            end
        end
    end
    util.yield(250)
end)

-- -- Collectibles
world_action_figures_root = menu.list(world_collectibles_root, "Action Figures...", {"ryanactionfigures"}, "Every action figure in the game.")
UI.CreateTeleportList(world_action_figures_root, "Action Figure", Ryan.ActionFigures)

world_signal_jammers_root = menu.list(world_collectibles_root, "Signal Jammers...", {"ryansignaljammers"}, "Every signal jammer in the game.")
UI.CreateTeleportList(world_signal_jammers_root, "Signal Jammer", Ryan.SignalJammers)

world_playing_cards_root = menu.list(world_collectibles_root, "Playing Cards...", {"ryanplayingcards"}, "Every playing card in the game.")
UI.CreateTeleportList(world_playing_cards_root, "Playing Card", Ryan.PlayingCards)

world_movie_props_root = menu.list(world_collectibles_root, "Movie Props...", {"ryanmovieprops"}, "Every movie prop in the Solomon Richards quest.")
UI.CreateTeleportList(world_movie_props_root, "Movie Prop", Ryan.MovieProps)

world_slasher_root = menu.list(world_collectibles_root, "The Slasher...", {"ryanslasher"}, "Everything needed to activate the Slasher event.")
menu.divider(world_slasher_root, "Step 1")
UI.CreateTeleportList(world_slasher_root, "Slasher Clue", Ryan.SlasherClues)
menu.divider(world_slasher_root, "Step 2")
UI.CreateTeleportList(world_slasher_root, "Slasher Van", Ryan.SlasherVans)
menu.divider(world_slasher_root, "Step 3")
slasher_spawn = menu.action(world_slasher_root, "Slasher Spawn", {"ryanslasherspawn"}, "Teleports to the Slasher's spawn location", function(click_type)
    menu.show_warning(slasher_spawn, click_type, "You must be on foot between 7pm and 5am for the Slasher to spawn here.", function()
        Player:Self().teleport({x = Ryan.SlasherFinale[1], y = Ryan.SlasherFinale[2], z = Ryan.SlasherFinale[3]}, false)
    end)
end)

world_treasure_hunt_root = menu.list(world_collectibles_root, "Treasure Hunt...", {"ryantreasures"}, "Every treasure in the Treasture Hunt.")
UI.CreateTeleportList(world_treasure_hunt_root, "Treasure", Ryan.Treasures)

world_usb_sticks_root = menu.list(world_collectibles_root, "USB Sticks...", {"ryanusbsticks"}, "Every USB Stick containing bonus music.")
UI.CreateTeleportList(world_usb_sticks_root, "USB Stick", Ryan.USBSticks)

-- -- All Entities Visible
menu.toggle_loop(world_root, "All Entities Visible", {"ryannoinvisible"}, "Makes all invisible entities visible again.", function()
    for _, player in pairs(Player:List(false, true, true)) do
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
        Ryan.DoFireworks(firework_coords, {x = math.random(-150, 150), y = math.random(-200, 50), z = math.random(-25, 25)})

        if math.random(1, 10) == 1 then
            local offset = v3(math.random(-75, 75), math.random(-75, 75), math.random(-25, 25))
            offset:add(v3(8, 8, 0)); Ryan.DoFireworks(firework_coords, offset)
            offset:add(v3(-16, 0, 0)); Ryan.DoFireworks(firework_coords, offset)
            offset:add(v3(16, -16, 0)); Ryan.DoFireworks(firework_coords, offset)
            offset:add(v3(-16, 0, 0)); Ryan.DoFireworks(firework_coords, offset)
        end
        if math.random(1, 10) == 2 then
            local offset = v3(math.random(-75, 75), math.random(-75, 75), math.random(-25, 25))
            for i = 1, math.random(3, 6) do
                util.yield(math.random(75, 500))
                offset:add(v3(8, i + 8, 0)); Ryan.DoFireworks(firework_coords, offset)
                offset:add(v3(0, (i + 8) * -2, 0)); Ryan.DoFireworks(firework_coords, offset)
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
UI.CreateList(world_root, "Remove", "ryanremove", "Clears the world of certain types of peds.", remove_modes, function(value)
    remove_mode = value
end)
util.create_tick_handler(function()
    if not CUTSCENE.IS_CUTSCENE_ACTIVE() then
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        for _, entity in pairs(Objects.GetAllNearCoords(coords, 500, Objects.Type.Ped)) do
            if ENTITY.IS_ENTITY_A_PED(entity) then
                pluto_switch remove_mode do
                    case "Cops":
                        for _, ped_type in pairs(Ryan.PedGroups.LawEnforcement) do
                            if PED.GET_PED_TYPE(entity) == ped_type then
                                Objects.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                Ryan.Toast("Removed a cop.")
                            end
                        end
                        break
                    case "Cayo Perico Guards":
                        for _, ped_hash in pairs(Ryan.PedModels.CayoPericoHeist) do
                            if ENTITY.GET_ENTITY_MODEL(entity) == ped_hash then
                                Objects.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                Ryan.Toast("Removed a Cayo Perico guard.")
                            end
                        end
                    case "Casino Guards":
                        for _, ped_hash in pairs(Ryan.PedModels.CasinoHeist) do
                            if ENTITY.GET_ENTITY_MODEL(entity) == ped_hash then
                                Ryan.Toast(ped_hash)
                                Objects.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                Ryan.Toast("Removed a Casino guard.")
                            end
                        end
                    case "Doomsday Guards":
                        for _, ped_hash in pairs(Ryan.PedModels.DoomsdayHeist) do
                            if ENTITY.GET_ENTITY_MODEL(entity) == ped_hash then
                                Objects.RequestControl(entity)
                                entities.delete_by_handle(entity)
                                Ryan.Toast("Removed a Doomsday guard.")
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
menu.toggle(world_all_vehicles_root, "Self", {"ryanallvehiclesown"}, "If enabled, your current vehicle is affected too.", function(value)
    all_vehicles_include_own = value
end)


menu.divider(world_all_vehicles_root, "Effects")
UI.CreateVehicleEffectList(world_all_vehicles_root, "ryanall", "", all_vehicles_effects, false, false)
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

    local vehicles = Objects.GetAllNearCoords(player_coords, 250, Objects.Type.Vehicle)
    for _, vehicle in pairs(vehicles) do
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        local player = if PED.IS_PED_A_PLAYER(driver) then Player:ByPedId(driver) else nil
        local friend = if player ~= nil then player:is_a_friend() else false

        if all_vehicles_include_own or vehicle ~= entities.get_user_vehicle_as_handle() then
            if (all_vehicles_include_players and player ~= nil and not friend)
            or (all_vehicles_include_friends and player ~= nil and friend)
            or (all_vehicles_include_npcs and not is_a_player) then
                UI.ApplyVehicleEffectList(vehicle, all_vehicles_effects, all_vehicles_state, player ~= nil, false)

                -- Flee
                if all_vehicles_effects.flee and player == nil and all_vehicles_state[vehicle].flee ~= true then
                    TASK.TASK_SMART_FLEE_PED(driver, players.user_ped(), 500.0, -1, false, false)
                    all_vehicles_state[vehicle].flee = true
                end

                -- Blind
                if all_vehicles_effects.blind and player == nil and (all_vehicles_state[vehicle].blind ~= true or math.random(1, 10) <= 3) then
                    Objects.MakeVehicleBlind(vehicle)
                    all_vehicles_state[vehicle].blind = true
                end
            end
        end
    end

    util.yield(500)
end)

-- -- Enter Closest Vehicle
enter_closest_vehicle = menu.action(world_root, "Enter Closest Vehicle", {"ryandrivevehicle"}, "Teleports into the closest vehicle.", function()
    local closest_vehicle = Objects.GetAllNearCoords(Player:Self().coords, 100, Objects.Type.Vehicle, false)[1]
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(closest_vehicle, -1)
    
    if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, -1) then
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), closest_vehicle, -1)
        Ryan.Toast("Teleported into the closest vehicle.")
    else
        if PED.GET_PED_TYPE(driver) >= 4 then
            entities.delete_by_handle(driver)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), closest_vehicle, -1)
            Ryan.Toast("Teleported into the closest vehicle.")
        elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(closest_vehicle) then
            for i = 0, 10 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(closest_vehicle, i) then
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), closest_vehicle, i)
                    break
                end
            end
            Ryan.Toast("Teleported into the closest vehicle.")
        else
            Ryan.Toast("No nearby vehicles found.")
        end
        
    end
end)

draw_closest_vehicle_esp = false
menu.on_focus(enter_closest_vehicle, function() draw_closest_vehicle_esp = true end)
menu.on_blur(enter_closest_vehicle, function() draw_closest_vehicle_esp = false end)

util.create_tick_handler(function()
    if draw_closest_vehicle_esp then
        local closest_vehicle = Objects.GetAllNearCoords(Player:Self().coords, 100, Objects.Type.Vehicle, false)[1]
        if closest_vehicle ~= 0 then Objects.DrawESP(closest_vehicle) end
    end
end)


-- Session Menu --
menu.divider(session_root, "General")
session_dox_root = menu.list(session_root, "Dox...", {"ryandox"}, "Shares information players probably want private.")
session_nuke_root = menu.list(session_root, "Nuke...", {"ryannuke"}, "Plays a siren, timer, and bomb with additional earrape.")
session_crash_all_root = menu.list(session_root, "Crash All...", {"ryancrashall"}, "The ultimate session crash.")
session_antihermit_root = menu.list(session_root, "Anti-Hermit...", {"ryanantihermit"}, "Handle players that never seem to go outside.")
session_max_players_root = menu.list(session_root, "Max Players...", {"ryanmax"}, "Kicks players when above a certain limit.")

-- -- Nuke
nuke_spam_enabled = false
nuke_spam_message = "Get Ryan's Menu for Stand!"

menu.action(session_nuke_root, "Go", {"ryannukego"}, "Starts the nuke.", function()
    Ryan.Toast("Nuke incoming.")
    Ryan.PlaySoundOnAllPlayers("DLC_sum20_Business_Battle_AC_Sounds", "Air_Defences_Activated"); util.yield(3000)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(1000)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(1000)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(500)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(500)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Ryan.PlaySoundOnAllPlayers("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING"); util.yield(125)
    Trolling.ExplodeAll(true)
    if nuke_spam_enabled then Session.SpamChat(nuke_spam_message, 100) end
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
    local player_list = Player:ListByNumberDescending(function(player) return players.get_money(player.id) end)
    message = player_list[1].name .. " is the richest player here ($" .. Ryan.FormatNumber(players.get_money(player_list[1].id)) .. ")."
    if #player_list > 1 then message = message .. " " .. player_list[#player_list].name .. " is the poorest ($" .. Ryan.FormatNumber(players.get_money(player_list[#player_list].id)) .. ")." end
    if message ~= "" then Ryan.SendChatMessage(message) end
end)
menu.action(session_dox_root, "K/D Ratio", {"ryankd"}, "Shares the name of the highest and lowest K/D players.", function()
    local player_list = Player:ListByNumberDescending(function(player) return players.get_kd(player.id) end)
    message = player_list[1].name .. " has the highest K/D here (" .. string.format("%.2f", players.get_kd(player_list[1].id)) .. ")."
    if #player_list > 1 then message = message .. " " .. player_list[#player_list].name .. " has the lowest (" .. string.format("%.1f", players.get_kd(player_list[#player_list].id)) .. ")." end
    if message ~= "" then Ryan.SendChatMessage(message) end
end)

menu.divider(session_dox_root, "List All")
menu.action(session_dox_root, "Godmode", {"ryangodmode"}, "Shares the name of the players in godmode.", function()
    local player_list, message = Player:ListByBoolean(function(player) return player:is_in_godmode() end), ""
    if #player_list > 0 then message = "Players likely in godmode: " .. Player:ListNames(player_list) .. "."
    else message = "No players are in godmode." end
    Ryan.SendChatMessage(message)
end)
menu.action(session_dox_root, "Off Radar", {"ryanoffradar"}, "Shares the name of the players off the radar.", function()
    local player_list, message = Player:ListByBoolean(function(player) return players.is_otr(player.id) end), ""
    if #player_list > 0 then message = "Players off-the-radar: " .. Player:ListNames(player_list) .. "."
    else message = "No players are off-the-radar." end
    Ryan.SendChatMessage(message)
end)
menu.action(session_dox_root, "Oppressor", {"ryanoppressor"}, "Shares the name of the players in Oppressors.", function()
    local player_list, message = Player:ListByBoolean(function(player) return player:is_on_oppressor2() end), ""
    if #player_list > 0 then message = "Players on Oppressors: " .. Player:ListNames(player_list) .. "."
    else message = "No players are on Oppressors." end
    Ryan.SendChatMessage(message)
end)

-- -- Crash All
crash_all_friends = false
crash_all_modders = false

menu.action(session_crash_all_root, "Stand Crash", {"ryancrashallstand"}, "Let the crashing commence.", function()
    for _, player in pairs(Player:List(false, crash_all_friends, crash_all_modders)) do
        player:crash()
        util.yield(500)
    end
end)

menu.action(session_crash_all_root, "Super Crash", {"ryancrashallsuper"}, "Let the crashing commence, epicly.", function()
    local crash_players = {}
    local block_players = {}

    for _, player in pairs(Player:List(false, true, true)) do
        if (crash_all_friends or not player:is_a_friend())
        and (crash_all_modders or not player:is_a_modder()) then
            table.insert(crash_players, player.name)
        else
            table.insert(block_players, player)
            player:block_syncs(true)
        end
    end
    
    for _, player_name in pairs(crash_players) do
        local player = Player:ByName(player_name)
        if player ~= nil then player:super_crash(false) end
    end

    for _, player in pairs(block_players) do
        player:block_syncs(false)
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

UI.CreateList(session_antihermit_root, "Mode", "ryanantihermit", "What to do with the hermits.", Ryan.AntihermitModes, function(value)
    antihermit_mode = value
end)
menu.slider(session_antihermit_root, "Time (Minutes)", {"ryanantihermittime"}, "How long, in minutes, to let players stay inside.", 1, 15, 5, 1, function(value)
    antihermit_time = value * 60000
end)
menu.toggle(session_antihermit_root, "Include Modders", {"ryanantihermitmodders"}, "If enabled, modders are included.", function(value)
    antihermit_include_modders = value
end)

hermits = {}
hermit_list = {}
util.create_tick_handler(function()
    if not PlayerIsSwitchingSessions then
        for _, player in pairs(Player:List(false, false, antihermit_include_modders)) do
            local tracked = false
            if players.is_in_interior(player.id) then
                if hermits[player.id] == nil then
                    hermits[player.id] = util.current_time_millis()
                    if antihermit_mode ~= "Off" then
                        Ryan.Toast(player.name .. " is now inside a building.")
                    end
                elseif hermit_list[player.id] ~= nil then
                    hermits[player.id] = util.current_time_millis() - (antihermit_time * 0.7)
                    hermit_list[player.id] = nil
                elseif util.current_time_millis() - hermits[player.id] >= antihermit_time then
                    hermits[player.id] = util.current_time_millis() - (antihermit_time * 0.7)
                    hermit_list[player.id] = true
                    if antihermit_mode ~= "Off" then
                        Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Anti-Hermit", player.name .. " has been inside for 5 minutes. Now doing: " .. antihermit_mode .. "!")
                        player:spam_sms("You've been inside too long. Stop being weird and play the game!", 1500)
                        pluto_switch antihermit_mode do
                            case "Teleport Outside":
                                menu.trigger_commands("apt1" .. player.name)
                                break
                            case "Kick":
                                player:kick()
                                break
                            case "Crash":
                                player:crash()
                                break
                        end
                    end
                end
            else
                if hermits[player_id] ~= nil then 
                    local time = Ryan.FormatTimespan(util.current_time_millis() - hermits[player_id])
                    if time ~= "" then
                        if antihermit_mode ~= "Off" then
                            Ryan.Toast(player_name .. " is no longer inside a building after " .. time .. ".")
                        end
                        hermits[player_id] = nil
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
        menu.trigger_commands("ryanmaxpreferhighestkd off; ryanmaxpreferrichest off")
        if not max_players_include_modders then menu.trigger_commands("ryanmaxincludemodders on") end
    end
    max_players_prefer_modders = value
end)
menu.toggle(session_max_players_root, "Richest", {"ryanmaxpreferrichest"}, "Kicks players with the highest balance first.", function(value)
    if value then menu.trigger_commands("ryanmaxpreferhighestkd off; ryanmaxprefermodders off") end
    max_players_prefer_richest = value
end)
menu.toggle(session_max_players_root, "Highest K/D", {"ryanmaxpreferhighestkd"}, "Kicks players with the most money first.", function(value)
    if value then menu.trigger_commands("ryanmaxpreferrichest off; ryanmaxprefermodders off") end
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
        local player_list = Player:List(true, true, true)
        if #player_list > max_players_amount then
            if max_players_prefer_modders or max_players_prefer_richest or max_players_prefer_highest_kd then
                table.sort(player_list, function(player_1, player_2)
                    if max_players_prefer_modders then
                        return (if player_1:is_a_modder() then 1 else 0) > (if player_2:is_a_modder() then 1 else 0)
                    elseif max_players_prefer_richest then
                        return players.get_money(player_1.id) > players.get_money(player_2.id)
                    elseif max_players_prefer_highest_kd then
                        return players.get_kd(player_1.id) > players.get_kd(player_2.id)
                    end
                end)
            end

            local kick_count = #player_list - max_players_amount
            local kicked = 0
            for _, player in ipairs(player_list) do
                local can_kick = (max_players_include_modders or not player:is_a_modder()) and (max_players_include_friends or not player:is_a_friend())
                if player.id ~= players.user() and can_kick and kicked < kick_count then
                    local reason = "no reason"
                    if max_players_prefer_modders then reason = "being a modder"
                    elseif max_players_prefer_richest then reason = "having $" .. Ryan.FormatNumber(players.get_money(player.id))
                    elseif max_players_prefer_highest_kd then reason = "having a " .. string.format("%.1f", players.get_kd(player.id)) .. " K/D" end
                    Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Max Players", "Kicking " .. player.name .. " for " .. reason .. ".")
                    player:kick()
                    kicked = kicked + 1
                end
            end
        end
    end
    util.yield(1000)
end)

-- -- NASA Satellite
Trolling.CreateNASAMenu(session_root, nil)

-- -- Turn Into Animals
turn_all_into_animals = false
menu.toggle(session_root, "Turn Into Animals", {"ryananimalall"}, "Turns all players into a random animal.", function(value) turn_all_into_animals = value end)

util.create_tick_handler(function()
    if turn_all_into_animals then
        for _, player in pairs(Player:List(true, true, true)) do
            player:turn_into_animal()
            util.yield(30000)
        end
    end
end)


-- Vehicle
menu.divider(session_root, "Vehicle")

-- -- Trolling
session_vehicle_trolling_root = menu.list(session_root, "Trolling...", {"ryantpvehicles"}, "Forces every vehicle into an area.")
    
menu.toggle_loop(session_vehicle_trolling_root, "Teleport To Me", {"ryantpme"}, "Teleports them to your location.", function()
    for _, player in pairs(Player:List(true, true, true)) do
        local user = Player:Self()
        if user.coords:distance(player.coords) > 33.33 then
            local coords = v3(user.coords)
            coords:add(v3(math.random(-10, 10), math.random(-10, 10), 0))
            player:teleport_vehicle(coords)
        end
    end
    util.yield(1000)
end)

menu.toggle_loop(session_vehicle_trolling_root, "Delete", {"ryandelete"}, "Deletes their vehicle.", function()
    for _, player_id in pairs(players.list()) do
        local vehicle = if players.get_vehicle_model(player_id) ~= 0 then PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id), false) else 0
        if vehicle ~= 0 then
            Objects.RequestControl(vehicle, false)
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
UI.CreateList(session_root, "Mk II", "ryanmk2", "How Oppressor Mk IIs are handled in the session.", mk2_modes, function(value)
    if mk2_mode == "Banned" then mk2_ban_notice = 0 end
    if mk2_mode == "Chaos" then mk2_chaos_notice = 0 end
    mk2_mode = value
end)

util.create_tick_handler(function()
    pluto_switch mk2_mode do
        case "Banned":
            if util.current_time_millis() - mk2_ban_notice >= 300000 then
                Ryan.SendChatMessage("This session is in Mk II Ban mode! Go ahead, try and use one.")
                mk2_ban_notice = util.current_time_millis()
            end

            local oppressor2 = util.joaat("oppressor2")
            local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            for _, vehicle in pairs(Objects.GetAllNearCoords(coords, 9999, Objects.Type.Vehicle)) do
                if VEHICLE.IS_VEHICLE_MODEL(vehicle, oppressor2) then
                    Objects.RequestControl(vehicle, false)
                    entities.delete_by_handle(vehicle)
                end
            end

            for _, player_id in pairs(players.list()) do
                if players.get_vehicle_model(player_id) == oppressor2 then
                    if mk2_ban_evaders[player_id] == nil then
                        mk2_ban_evaders[player_id] = util.current_time_millis()
                    elseif util.current_time_millis() - mk2_ban_evaders[player_id] >= 2000 and mk2_ban_warnings[player_id] == nil then
                        Ryan.Toast(players.get_name(player_id) .. " is still on a Mk II. Sending them a warning.")
                        Player:Get(player_id):send_sms("WARNING: Get off of your Mk II or you will be kicked!")
                        mk2_ban_warnings[player_id] = true
                    elseif util.current_time_millis() - mk2_ban_evaders[player_id] >= 10000 then
                        Ryan.Toast("Kicking " .. players.get_name(player_id) .. " for not getting off their Mk II.")
                        Player:Get(player_id):kick()
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
                Ryan.SendChatMessage("This session is in Mk II Chaos mode! Type \"!mk2\" in chat at any time to get one. Good luck.")
                
                local oppressor2 = util.joaat("oppressor2")
                Ryan.RequestModel(oppressor2)

                for _, player in Player:List(true, true, true) do
                    local coords = v3(player.coords)
                    local direction = ENTITY.GET_ENTITY_ROTATION(player.ped_id, 2):toDir()
                    direction:mul(7.5); coords:add(direction)
                    local vehicle = entities.create_vehicle(oppressor2, coords, ENTITY.GET_ENTITY_HEADING(player.ped_id))
                    Objects.RequestControl(vehicle, true)
                    Objects.SetVehicleFullyUpgraded(vehicle, true)
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
                    VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, true)
                    VEHICLE.SET_VEHICLE_DOOR_LATCHED(vehicle, 0, false, false, true)
                end

                Ryan.FreeModel(oppressor2)
            end
            break
    end
end)


-- Stats Menu --
menu.divider(stats_root, "Player")
stats_kd_root = menu.list(stats_root, "Kills/Deaths...", {"ryankd"}, "Controls your kills and deaths.")
UI.UpdateKDMenu(stats_kd_root)

menu.divider(stats_root, "World")

stats_office_money_root = menu.list(stats_root, "CEO Office Money...", {"ryanofficemoney"}, "Controls the amount of money in your CEO office.")
UI.CreateOfficeMoneyButton(stats_office_money_root, 0, 0)
UI.CreateOfficeMoneyButton(stats_office_money_root, 25, 5000000)
UI.CreateOfficeMoneyButton(stats_office_money_root, 50, 10000000)
UI.CreateOfficeMoneyButton(stats_office_money_root, 75, 15000000)
UI.CreateOfficeMoneyButton(stats_office_money_root, 100, 20000000)

stats_mc_clutter_root = menu.list(stats_root, "MC Clubhouse Clutter...", {"ryanmcclutter"}, "Controls the amount of clutter in your clubhouse.")
UI.CreateMCClutterButton(stats_mc_clutter_root, 0, 0)
UI.CreateMCClutterButton(stats_mc_clutter_root, 100, 20000000)


-- Chat Menu --
menu.divider(chat_root, "Translate")
chat_new_message_root = menu.list(chat_root, "New Message...", {"ryanchatnew"})
chat_history_root = menu.list(chat_root, "Message History...", {"ryanchathistory"})

-- -- Send Message
chat_languages = {"No"}; for i = 1, #Ryan.Languages do table.insert(chat_languages, Ryan.Languages[i][1]) end
chat_symbols = {{"None", ""}, {"R* Logo", "∑"}, {"R* Verified", "¦"}, {"Padlock", "Ω"}}

chat_prefix = ""
chat_message = ""

function chat_preview(symbol)
    local preview = symbol .. (if symbol:len() > 0 and chat_message:len() > 0 then " " else "") .. chat_message
    util.show_corner_help("<b>Preview:</b>\n" .. (if preview:len() > 0 then preview else "\n"))
end

UI.CreateList(chat_new_message_root, "Translate", "ryanchattranslate", "Translate the message into another language.", chat_languages, function(value)
    chat_translate = value
end)
chat_add_symbol_root = menu.list(chat_new_message_root, "Add Symbol: None", {"ryanchatsymbol"}, "Add a symbol to the message.")
for _, symbol in pairs(chat_symbols) do
    local action = menu.action(chat_add_symbol_root, symbol[1], {"ryanchat" .. Ryan.CommandName(symbol[1])}, "", function()
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
        Ryan.SendChatMessage(chat_prefix .. chat_message)
    else
        for _, language in pairs(Ryan.Languages) do
            if language[1] == chat_translate then
                Ryan.Translate(chat_message, language[2], language[3], function(result)
                    Ryan.SendChatMessage(chat_prefix .. message)
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

function reply(message) Ryan.SendChatMessage("∑ " .. message .. " ∑") end
chat.on_message(function(packet_sender, sender, message, is_team_chat)
    local message_lower = message:lower()
    local sender_name = players.get_name(sender)
    if crash_money_beggars then
        if (message_lower:find("can") or message_lower:find("?") or message_lower:find("please") or message_lower:find("plz") or message_lower:find("pls") or message_lower:find("drop"))
        and message_lower:find("money") then
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Crash Money Beggars", players.get_name(sender) .. " is being crashed for begging for money drops.")
            Player:Get(sender):crash()
        end
    end
    if crash_car_meeters then
        if (message_lower:find("want to") or message_lower:find("wanna") or message_lower:find("at") or message_lower:find("is") or message_lower:find("?"))
        and message_lower:find("car") and message_lower:find("meet") then
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Crash Car Meeters", players.get_name(sender) .. " is being crashed for suggesting a car meet.")
            Player:Get(sender):crash()
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
                            local player = Player:ByName(args[i])
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
                                Ryan.RequestModel(oppressor2)

                                local player = Player:Get(sender)
                                local coords = player:get_coords()
                                local direction = ENTITY.GET_ENTITY_ROTATION(player.ped_id, 2):toDir()
                                direction:mul(7.5); coords:add(direction)
                                Objects.RequestControl(vehicle, true)
                                Objects.SetVehicleFullyUpgraded(vehicle, true)
                                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
                                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, true)
                                VEHICLE.SET_VEHICLE_DOOR_LATCHED(vehicle, 0, false, false, true)

                                Ryan.FreeModel(oppressor2)
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
            Ryan.Toast("Translating...")
            Ryan.Translate(message, "EN", false, function(result)
                Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Translation", result)
            end)
        end)
    )
    chat_index = chat_index + 1
end)


-- Settings Menu --
menu.divider(settings_root, "Updates")
menu.action(settings_root, "Version: " .. VERSION, {}, "The currently installed version.", function() end)
menu.action(settings_root, "Reinstall", {"ryanreinstall"}, "Force update the script for patches and troubleshooting.", function() Ryan.DoUpdate(true) end)
menu.hyperlink(settings_root, "Website", "https://gta.ryanmade.site/", "Opens the official website, for downloading the installer and viewing the changelog.")

menu.divider(settings_root, "HUD")
hud_color = menu.colour(settings_root, "Color", {"ryanhudcolor"}, "The color of on-screen ESP.", 0.29, 0.69, 1.0, 1.0, false, function(value)
    Ryan.HUDColor.r = value.r
    Ryan.HUDColor.g = value.g
    Ryan.HUDColor.b = value.b
end)
hud_use_beacons = menu.toggle(settings_root, "Use Beacons", {"ryanhudbeacons"}, "Use AR Beacons instead of ESP.", function(value)
    Ryan.HUDUseBeacon = value
end)
menu.toggle(settings_root, "Text Keybinds", {"ryantextkeybinds"}, "Enable this to fix flickering in the God Finger menu.", function(value)
    Ryan.TextKeybinds = value
end)

hud_preview = 0
menu.on_focus(hud_color, function() hud_preview = hud_preview + 1 end)
menu.on_focus(hud_use_beacons, function() hud_preview = hud_preview + 1 end)
menu.on_blur(hud_color, function() hud_preview = hud_preview - 1 end)
menu.on_blur(hud_use_beacons, function() hud_preview = hud_preview - 1 end)

util.create_tick_handler(function()
    if hud_preview > 0 then
        if Ryan.HUDUseBeacon then Ryan.DrawBeacon(ENTITY.GET_ENTITY_COORDS(players.user_ped()))
        else Objects.DrawESP(players.user_ped()) end
    end
end)

-- Player Options --
spectate_buttons = {}

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

function Player:OnJoin(player)
    if player.id ~= players.user() then
        spectate_buttons[player.id] = menu.toggle(world_spectate_root, player.name, {"ryanspectate" .. player.name}, "Spectate the player.", function(value)
            if value then
                for player_id, button in pairs(spectate_buttons) do
                    if player_id ~= player.id then
                        menu.trigger_command(button, "off")
                    end
                end
            end
            menu.trigger_commands("spectate" .. player.name .. " " .. (if value then "on" else "off"))
        end)
    end

    local player_root = menu.player_root(player.id)
    menu.divider(player_root, "Ryan's Menu")

    local player_name = players.get_name(player.id)
    local player_trolling_root = menu.list(player_root, "Trolling...", {"ryantrolling"}, "Options that players may not like.")
    local player_removal_root = menu.list(player_root, "Removal...", {"ryanremoval"}, "Options to remove the player forcibly.")

    
    -- Trolling --
    -- -- Kill
    local player_trolling_kill_root = menu.list(player_trolling_root, "Kill...", {"ryankill"}, "Options to kill players while they're in godmode.")
    
    menu.toggle(player_trolling_kill_root, "Remove Godmode", {"ryankillgodmode"}, "Remove godmode from players using Kiddions or inside a building.", function(value)
        remove_godmode[player.id] = if value then true else nil
    end)

    menu.toggle_loop(player_trolling_kill_root, "Kill (Kiddions)", {"ryankillstungun"}, "Use this to kill players using Kiddions godmode. May also work in some buildings.", function()
        local stun_gun = util.joaat("weapon_stungun")
        local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)
		WEAPON.REQUEST_WEAPON_ASSET(stun_gun)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), stun_gun, 1, false, true)
        player:remove_godmode()
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z + 1, coords.x, coords.y, coords.z, 1000, true, stun_gun, 0, false, true, 1.0)
    end)

    menu.toggle_loop(player_trolling_kill_root, "Kill (Interior)", {"ryankillsnowball"}, "Use this to kill players inside buildings. May also work on some menus' godmodes.", function()
		local snowball = util.joaat("weapon_snowball")
        local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)
		WEAPON.REQUEST_WEAPON_ASSET(snowball)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), snowball, 10, false, true)
        player:remove_godmode()
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 2, 200, 0, snowball, 0, true, false, 2500.0)
    end)

    menu.action(player_trolling_kill_root, "Kill (Paid Menu)", {"ryankillphysics"}, "Use this when removing godmode does not work.", function()
        player:squish()
    end)


    -- -- Spawn
    local player_trolling_spawn_root = menu.list(player_trolling_root, "Spawn...", {"ryanspawn"}, "Entity trolling options.")
    
    Trolling.CreateNASAMenu(player_trolling_spawn_root, player.id)
    menu.action(player_trolling_spawn_root, "Military Squad", {"ryanmilitarysquad"}, "Send an entire fucking military squad.", function()
		Trolling.MilitarySquad(player.id, true)
    end)
    menu.action(player_trolling_spawn_root, "SWAT Raid", {"ryanswatraid"}, "Sends a SWAT team to kill them, brutally.", function()
        Trolling.SWATTeam(player.id)
    end)
    menu.action(player_trolling_spawn_root, "Flying Yacht", {"ryanflyingyacht"}, "Send the magic school yacht to fuck their shit up.", function()
        Trolling.FlyingYacht(player.id)
    end)
    menu.action(player_trolling_spawn_root, "Falling Tank", {"ryanfallingtank"}, "Send a tank straight from heaven.", function()
		Trolling.FallingTank(player.id)
    end)

    menu.divider(player_trolling_spawn_root, "Options")
    menu.action(player_trolling_spawn_root, "Delete All", {"ryanentitiesdelete"}, "Deletes all previously spawned entities.", function()
        Trolling.DeleteEntities(player.id)
    end)

    -- -- Attach
    attach_root[player.id] = menu.list(player_trolling_root, "Attach...", {"ryanattach"}, "Attaches to their vehicle on a specific bone.")
    attach_vehicle_offset[player.id] = 0.0
    attach_notice[player.id] = nil
    attach_vehicle_bones[player.id] = {}

    menu.action(attach_root[player.id], "Detach", {"ryandetach"}, "Detaches from anything you're attached to.", function()
        ENTITY.DETACH_ENTITY(players.user_ped(), false, false)
        Ryan.Toast("Detached from all entities.")
    end)
    menu.slider(attach_root[player.id], "Offset", {"ryanattachoffset"}, "Offset of the Z coordinate.", -25, 25, 1, 0, function(value)
        attach_vehicle_offset[player.id] = value
    end)


    menu.divider(attach_root[player.id], "Attach To")
    menu.action(attach_root[player.id], "Player", {"ryanattachplayer"}, "Attach to the player.", function()
        if player.id == players.user() then
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Attach", "You just almost crashed yourself. Good job!")
            return
        end

        ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), player.ped_id, 0, 0.0, -0.2, (attach_vehicle_offset[player.id] * 0.2), 1.0, 1.0, 1, true, true, true, false, 0, true)
        Ryan.Toast("Attached to " .. player.name .. ".")
    end)

    -- -- Vehicle
    local player_vehicle_root = menu.list(player_trolling_root, "Vehicle...", {"ryanvehicle"}, "Vehicle trolling options.")    

    vehicle_effects[player.id] = {}
    UI.CreateVehicleEffectList(player_vehicle_root, "ryan", player.name, vehicle_effects[player.id], true, false)

    menu.toggle(player_vehicle_root, "Leash", {"ryanleash"}, "Brings their vehicle with you like a leash.", function(value)
        vehicle_effects[player.id].leash = if value then true else nil
    end)

    -- -- Miscellaneous
    menu.toggle(player_trolling_root, "Fake Money Drop", {"ryanfakemoney"}, "Drops fake money bags on the player.", function(value)
        money_drop[player.id] = if value then true else nil
    end)
    menu.toggle_loop(player_trolling_root, "Turn Into Animal", {"ryananimal"}, "Turns the player into a random animal.", function()
        player:turn_into_animal()
        util.yield(30000)
    end)
    menu.action(player_trolling_root, "Steal Vehicle", {"ryansteal"}, "Steals the player's car.", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player.ped_id)
        if vehicle ~= 0 then Objects.StealVehicle(vehicle)
        else Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Steal Vehicle", player.name .. " is not in a vehicle.") end
    end)
    local player_trolling_glitch_root = UI.CreateList(player_trolling_root, "Glitch", "ryanglitch", "Glitch the player and their vehicle.", glitch_type_names, function(value)
        for i = 1, #glitch_type_names do
            if glitch_type_names[i] == value then
                glitch[player.id] = glitch_type_hashes[i]
            end
        end
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
        player:spam_sms_and_block_joins(removal_block_joins, removal_message, function()
            player:kick()
        end)
    end)
    menu.action(player_removal_root, "Stand Crash", {"ryancrash"}, "Use the best possible crash methods.", function()
        player:spam_sms_and_block_joins(removal_block_joins, removal_message, function()
            player:crash()
        end)
    end)
    menu.action(player_removal_root, "Super Crash", {"ryansuper"}, "A crash that should work on 2take1 and Cherax.", function()
        player:spam_sms_and_block_joins(removal_block_joins, removal_message, function()
            player:super_crash(true)
        end)
    end)


    -- Divorce Kick --
    menu.action(player_root, "Divorce", {"div"}, "Kicks the player, then blocks future joins by them.", function()
        menu.trigger_commands("historyblock" .. player.name)
        player:kick()
    end)
end

function Player:OnLeave(player)
    if spectate_buttons[player.id] ~= nil then
        menu.delete(spectate_buttons[player.id])
        spectate_buttons[player.id] = nil
    end

    money_drop[player.id] = nil
    ptfx_attack[player.id] = nil
    remove_godmode[player.id] = nil
    entities_message[player.id] = nil
    
    vehicle_effects[player.id] = nil

    attach_vehicle_bones[player.id] = nil
    attach_vehicle_id[player.id] = nil
    attach_notice[player.id] = nil
    attach_vehicle_offset[player.id] = nil
    attach_root[player.id] = nil

    glitch[player.id] = nil
    glitch_state[player.id] = nil

    hermits[player.id] = nil
    hermit_list[player.id] = nil

    Trolling.DeleteEntities(player.id)
end

util.create_tick_handler(function()
    for _, player in pairs(Player:List(true, true, true)) do
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player.id), true)
        if vehicle ~= 0 and vehicle_effects[player.id] ~= nil then
            UI.ApplyVehicleEffectList(vehicle, vehicle_effects[player.id], vehicle_state, true, false)

            -- Leash
            if vehicle_effects[player.id].leash == true then
                local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
                local coords = v3(Player:Self().coords)
                if vehicle_coords:distance(coords) > 5 then
                    coords:sub(vehicle_coords); coords:normalise()
                    Objects.RequestControl(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, coords.x * 5, coords.y * 5, coords.z * 5, 0, 0, 0.5, 0, false, false, true)
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
            if enabled then Player:Get(player_id):drop_fake_money() end
        end
        util.yield()
    end
end)

util.create_tick_handler(function()
    for _, player_id in pairs(players.list()) do
        if attach_root[player_id] ~= nil then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(Player:Get(player_id).ped_id, true)
            if vehicle ~= attach_vehicle_id[player_id] then
                for _, bone in pairs(attach_vehicle_bones[player_id]) do menu.delete(bone) end
                attach_vehicle_bones[player_id] = {}

                for i = 1, #VehicleAttachBones do
                    local bone = if VehicleAttachBones[i][2] ~= nil then ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, VehicleAttachBones[i][2]) else 0

                    if bone ~= -1 then
                        table.insert(
                            attach_vehicle_bones[player_id],
                            menu.action(attach_root[player_id], VehicleAttachBones[i][1], {"ryanattach" .. VehicleAttachBones[i][1]}, "Attaches to the bone.", function()
                                local vehicle = PED.GET_VEHICLE_PED_IS_IN(Player:Get(player_id).ped_id, true)
                                ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), vehicle, bone, 0.0, -0.2, (if bone == 0 then 2.0 else 1.0) + (attach_vehicle_offset[player_id] * 0.2), 1.0, 1.0, 1, true, true, true, false, 0, true)
                                Ryan.Toast("Attached to " .. players.get_name(player_id) .. "'s vehicle.")
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

spectate_notice = nil
util.create_tick_handler(function()
    for _, player in pairs(Player:List(true, true, true)) do
        local buttons = 0
        for player_id, button in pairs(spectate_buttons) do buttons = buttons + 1 end

        if buttons > 0 and spectate_notice ~= nil then
            menu.delete(spectate_notice)
            spectate_notice = nil
        elseif buttons == 0 and spectate_notice == nil then
            spectate_notice = menu.divider(world_spectate_root, "No Players")
        end

        if remove_godmode[player.id] == true then
            player:remove_godmode()
        end

        if glitch_state[player.id] ~= glitch[player.id] then
            util.create_thread(function()
                local glitch_type = glitch[player.id]
                while glitch[player.id] == glitch_type do
                    pluto_switch glitch_type do
                        case "Off":
                            break
                        case "Default":
                            local shuttering = util.joaat("prop_shuttering03")
                            Ryan.RequestModel(shuttering)
                            
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

                            Ryan.FreeModel(shuttering)
                            break
                        pluto_default:
                            local glitch_object, rallytruck = util.joaat(glitch[player.id]), util.joaat("rallytruck")
                            Ryan.RequestModel(glitch_object)
                            Ryan.RequestModel(rallytruck)

                            local player_coords = ENTITY.GET_ENTITY_COORDS(player.ped_id, false)

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
                            Ryan.FreeModel(glitch_object)
                            Ryan.FreeModel(rallytruck)
                    end
                    util.yield()
                end
                return false
            end)
            glitch_state[player.id] = glitch[player.id]
        end
    end
end)


Player:Init()
util.keep_running()

while true do
    if crosshair or god_finger_active then
        local weapon = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
        if WEAPON.GET_WEAPONTYPE_GROUP(weapon) ~= -1212426201 then
            HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
        end
        directx.draw_texture(
            Ryan.CrosshairTexture,
            0.03, 0.03,
            0.5, 0.5,
            0.5, 0.5,
            0.0,
            {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
        )
    end
    util.yield()
end