Trolling = {}

_entities = {}
Trolling.AddEntity = function(player_id, entity, with_blip)
    if _entities[player_id] == nil then _entities[player_id] = {} end
    table.insert(_entities[player_id], entity)
    if with_blip then HUD.ADD_BLIP_FOR_ENTITY(entity) end
end
Trolling.DeleteEntities = function(player_id)
    if _entities[player_id] == nil then return end

    for _, entity in pairs(_entities[player_id]) do entities.delete_by_handle(entity) end
    _entities[player_id] = {}
end

Trolling.MilitarySquad = function(player_id, with_crusaders)
    local player = Player:Get(player_id)
    local player_coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)

    local blackops = util.joaat("s_m_y_blackops_01")
    Ryan.RequestModel(blackops)
    local vehicles = if with_crusaders then {"apc", "apc", "crusader", "crusader", "crusader"} else {"apc", "apc"}
    for i = 1, #vehicles do
        vehicles[i] = util.joaat(vehicles[i])
        Ryan.RequestModel(vehicles[i])
    end

    for i = 1, #vehicles do
        local node_ptr = memory.alloc()
        local coords = v3.new()

        if not PATHFIND.GET_RANDOM_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, 80, 0, 0, 0, coords, node_ptr) then
            player_coords.x = player_coords.x + math.random(-20, 20)
            player_coords.y = player_coords.y + math.random(-20, 20)
            PATHFIND.GET_CLOSEST_VEHICLE_NODE(player_coords.x, player_coords.y, player_coords.z, coords, 1, 100, 2.5)
        end

        local vehicle = entities.create_vehicle(vehicles[i], coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        Trolling.AddEntity(player.id, vehicle, i < 3)
        local rotation = coords:lookAt(ENTITY.GET_ENTITY_COORDS(player.ped_id))
        ENTITY.SET_ENTITY_ROTATION(vehicle, rotation.x, rotation.y, rotation.z, 2, true)
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
        Objects.SetVehicleSpeed(vehicle, Objects.VehicleSpeed.Fast)
        Objects.SetVehicleFullyUpgraded(vehicle, true)

        local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vehicles[i])
        for seat = -1, seats - 2 do
            local ped = entities.create_ped(29, blackops, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
            Trolling.AddEntity(player.id, ped, false)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)
            WEAPON.GIVE_WEAPON_TO_PED(ped, 3686625920, -1, false, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)
            PED.SET_PED_MAX_HEALTH(ped, 500)
            ENTITY.SET_ENTITY_HEALTH(ped, 500)
            PED.SET_PED_SHOOT_RATE(ped, 1000)
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, blackops)
            TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 1000, 0)
        end
    end

    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, blackops, PED.GET_PED_RELATIONSHIP_GROUP_HASH(player.ped_id))
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, PED.GET_PED_RELATIONSHIP_GROUP_HASH(player.ped_id), blackops)
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, blackops, blackops)

    Ryan.FreeModel(blackops)
    for i = 1, #vehicles do
        Ryan.FreeModel(vehicles[i])
    end
end

Trolling.SWATTeam = function(player_id)
    local player = Player:Get(player_id)
    local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)

    local swat = util.joaat("s_m_y_swat_01")
    Ryan.RequestModel(swat)
    
    for i = 1, 4 do
        coords:add(v3(math.random(-3, 3), math.random(-3, 3), 0))
        local ped = entities.create_ped(5, swat, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        Trolling.AddEntity(player.id, ped, i == 1)

        WEAPON.GIVE_WEAPON_TO_PED(ped, -1312131151, -1, false, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)
        PED.SET_PED_MAX_HEALTH(ped, 500)
        ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        PED.SET_PED_SHOOT_RATE(ped, 1000)
        WEAPON.SET_PED_INFINITE_AMMO(ped, true, -1312131151)
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
        PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, swat)
        TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 100, 0)
        util.yield(375)
    end

    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, swat, PED.GET_PED_RELATIONSHIP_GROUP_HASH(player.ped_id))
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, PED.GET_PED_RELATIONSHIP_GROUP_HASH(player.ped_id), swat)
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, swat, swat)

    Ryan.FreeModel(swat)
end

Trolling.FlyingYacht = function(player_id)
    local big_boat, buzzard, blackops = util.joaat("prop_cj_big_boat"), util.joaat("buzzard2"), util.joaat("s_m_y_blackops_01")
    Ryan.RequestModel(big_boat); Ryan.RequestModel(buzzard); Ryan.RequestModel(blackops)

    local player = Player:Get(player_id)
    local player_group = PED.GET_PED_RELATIONSHIP_GROUP_HASH(player_ped)
    local coords = ENTITY.GET_ENTITY_COORDS(player_ped)

    local vehicle = entities.create_vehicle(buzzard, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    local attachment = entities.create_object(big_boat, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    Trolling.AddEntity(player_id, attachment, false); Trolling.AddEntity(player_id, vehicle, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.VEH_TO_NET(vehicle), false)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) then
        local ped = entities.create_ped(29, blackops, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        Trolling.AddEntity(player_id, ped, false)
        PED.SET_PED_INTO_VEHICLE(ped, vehicle)
        
        coords.x = coords.x + math.random(-20, 20)
        coords.y = coords.y + math.random(-20, 20)
        coords.z = coords.z + 30

        ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.VEH_TO_NET(vehicle), false)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
        VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehicle)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(attachment, vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "chassis"), 0, 0, 0, 0, 0, 0, false, false, false, false, 0, true)
        HUD.ADD_BLIP_FOR_ENTITY(vehicle)

        PED.SET_PED_MAX_HEALTH(ped, 500)
        ENTITY.SET_ENTITY_HEALTH(ped, 500)
        ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        TASK.TASK_HELI_MISSION(ped, vehicle, 0, player_ped, 0.0, 0.0, 0.0, 23, 40.0, 40.0, -1.0, 0, 10, -1.0, 0)
        PED.SET_PED_KEEP_TASK(ped, true)

        for seat = 1, 2 do 
            local ped = entities.create_ped(29, blackops, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
            Trolling.AddEntity(player_id, ped, false)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)
            WEAPON.GIVE_WEAPON_TO_PED(ped, 3686625920, -1, false, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)
            PED.SET_PED_MAX_HEALTH(ped, 500)
            ENTITY.SET_ENTITY_HEALTH(ped, 500)
            PED.SET_PED_SHOOT_RATE(ped, 1000)
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, blackops)
            TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 1000, 0)
        end

        util.yield(100)
    end

    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, blackops, PED.GET_PED_RELATIONSHIP_GROUP_HASH(player.ped_id))
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, PED.GET_PED_RELATIONSHIP_GROUP_HASH(player.ped_id), blackops)
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, blackops, blackops)

    Ryan.FreeModel(big_boat); Ryan.FreeModel(buzzard); Ryan.FreeModel(blackops)
end

Trolling.FallingTank = function(player_id)
    local player = Player:Get(player_id)
    local coords = ENTITY.GET_ENTITY_COORDS(player.ped_id)
    coords.z = coords.z + 5

    local tank = util.joaat("rhino")
    Ryan.RequestModel(tank)
    
    local entity = entities.create_vehicle(tank, coords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    Trolling.AddEntity(player_id, entity, true)
    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(entity, true)
    ENTITY.SET_ENTITY_MAX_SPEED(entity, 64)
    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 3, 0.0, 0.0, -1000.00, 0.0, 0.0, 0.0, 0, true, true, false, true)

    Ryan.FreeModel(tank)
end

Trolling.CreateNASAMenu = function(root, player_id)
    local command = "ryannasa" .. (if not player_id then "all" else "")
    local message = "who asked"
    local nasa_root = menu.list(root, "NASA Satellite...", {command}, "Use NASA satellites to discover something.")

    menu.text_input(nasa_root, "Find", {command .. "find"}, "What we're trying to find.", function(value)
        message = value
    end, "who asked")

    function go(player_id)
        local bigradar = util.joaat("prop_air_bigradar")
        Ryan.RequestModel(bigradar)

        local player_ped = Player:Get(player_id).ped_id
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
        local radar = entities.create_object(bigradar, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0, 20, -3), ENTITY.GET_ENTITY_HEADING(player_ped))
        Objects.RequestControl(radar, false)
        Trolling.AddEntity(player_id, radar, true)
        
        util.yield(10000)
        entities.delete_by_handle(radar)
        Ryan.FreeModel(bigradar)
    end
    
    menu.action(nasa_root, "Go", {command .. "go"}, "Spawn a NASA satellite to discover something.", function()
        if player_id then go(player_id)
        else for _, player_id in pairs(players.list()) do util.create_thread(function() go(player_id) end) end end
        Ryan.SendChatMessage("Using NASA satellites to find " .. message .. ".")
    end)
end

Trolling.ExplodeAll = function(with_earrape)
    if with_earrape then -- Credit: Bed Sound
        for _, coords in pairs(Ryan.BedSoundCoords) do
            Ryan.PlaySoundAtCoords(coords, "WastedSounds", "Bed", 999999999)
            coords.z = 2000.0
            Ryan.PlaySoundAtCoords(coords, "WastedSounds", "Bed", 999999999)
            coords.z = -2000.0
            Ryan.PlaySoundAtCoords(coords, "WastedSounds", "Bed", 999999999)
        end
    end
    
    for _, player in pairs(Player:List(true, true, true)) do
        player:explode(with_earrape)
    end
end

Trolling.VehicleControlModes = {
    Control = {{"Clone", "clone"}, {"Mk II", "oppressor2"}},
    Tow = {{"Jet", "hydra"}, {"Truck", "caracara2"}, {"Bicycle", "scorcher"}, {"Semi", "hauler"}, {"Cop Car", "police3"}, {"Cop Motorcycle", "policeb"}, {"Cop Helicopter", "polmav"}}
}

Trolling.CreateVehicleControl = function(root, player, name, with_trailer, model)
    local description = if name == "Clone" then "clone of their vehicle" else name
    local command = "ryanvcontrol" .. Ryan.CommandName(name)
    menu.toggle(root, "With " .. name, {command}, (if with_trailer then "Tow" else "Control") .. " their vehicle with a " .. description .. ".", function(value)
        if value then
            Trolling.DeactivateVehicleControl(player, name)
            if not Trolling.TakeControlOfVehicle(player, with_trailer, model, command) then
                menu.trigger_command(menu.ref_by_rel_path(root, "With " .. name), "off")
            end
        else
            Trolling.ReturnControlOfVehicle(player)
        end
    end)
end

Trolling.DeactivateVehicleControl = function(player, ignore_choice)
    local player_root = menu.player_root(player.id)

    local modes = {}
    for _, mode in pairs(Trolling.VehicleControlModes.Control) do table.insert(modes, mode) end
    for _, mode in pairs(Trolling.VehicleControlModes.Tow) do table.insert(modes, mode) end

    for _, mode in pairs(modes) do
        if mode[1] ~= ignore_choice then
            local ref = menu.ref_by_rel_path(player_root, "Trolling...>Control...>With " .. mode[1])
            if menu.get_value(ref) then
                menu.trigger_command(ref, "off")
                util.yield(750)
            end
        end
    end
end

Trolling.ControlledVehicles = {}
_was_in_ghost_mode = false

Trolling.TakeControlOfVehicle = function(player, model, with_trailer)    
    if players.get_vehicle_model(player.id) == 0 then
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Vehicle Control", player.name .. " is not driving a vehicle.")
        return false
    end
    if Trolling.ControlledVehicles[player.id] ~= nil then
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Vehicle Control", "You're already controlling " .. player.name .. "'s vehicle.")
        return
    end

    Trolling.ControlledVehicles[player.id] = {model = model, ghost_mode = Ryan.GhostMode}
    if not with_trailer and Ryan.GhostMode ~= 2 then
        local ghost_menu = menu.ref_by_path("Stand>Lua Scripts>" .. SUBFOLDER_NAME .. ">Self>Character...>Ghost Mode")
        menu.trigger_command(menu.ref_by_rel_path(ghost_menu, "Character Only"))
    end

    if Player:Self().coords:distance(player.coords) > 75 then
        Ryan.Teleport(Ryan.GetClosestNode(player.coords), true)
    end
    
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player.ped_id)
    local vehicle_data = Objects.GetVehicleData(vehicle)
    local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
    local vehicle_velocity = ENTITY.GET_ENTITY_VELOCITY(vehicle)
    
    local clone_model = if model ~= "clone" then util.joaat(model) else vehicle_data.model; Ryan.RequestModel(clone_model)
    local clone_coords = v3(vehicle_coords); clone_coords:add(v3(0, 0, 5))
    local clone_heading = ENTITY.GET_ENTITY_HEADING(vehicle)
    
    local vehicle_min, vehicle_max = v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(vehicle_data.model, vehicle_min, vehicle_max)
    local clone_min, clone_max = v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(clone_model, clone_min, clone_max)

    local clone = entities.create_vehicle(clone_model, clone_coords, clone_heading)
    if model == "clone" then Objects.SetVehicleData(clone, vehicle_data) end
    if model == "polmav" then 
        VEHICLE.SET_VEHICLE_MOD_KIT(clone, 0)
        VEHICLE.SET_VEHICLE_MOD(clone, 48, -1)
    end

    local offset = v3(0, 0, 0)
    if with_trailer then
        local trailer_model = util.joaat("prop_byard_trailer02"); Ryan.RequestModel(trailer_model)
        local trailer = entities.create_object(trailer_model, clone_coords)

        local trailer_min, trailer_max = v3.new(), v3.new()
        MISC.GET_MODEL_DIMENSIONS(trailer_model, trailer_min, trailer_max)
        
        offset:setY(clone_min.y + trailer_min.y + 0.5)
        offset:setZ(-0.25)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(trailer, clone, 0, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, false, true, false, false, 2, true)

        Trolling.ControlledVehicles[player.id].trailer = trailer
    end

    offset:setY(if with_trailer then vehicle_min.y + clone_min.y - 0.5 else 0)
    offset:setZ(if with_trailer then -vehicle_min.z else 0)
    
    local attached = false
    for i = 1, 10 do
        if not ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(clone, vehicle) then
            if i > 1 then Ryan.Toast("Still trying to take control of " .. player.name .. "'s vehicle.") end
            Objects.RequestControl(vehicle, true)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle, clone, 0, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, false, true, false, false, 2, true)
            Objects.SetVehicleDoorsLocked(vehicle, true)
            util.yield(100)
        else
            attached = true
            break
        end
    end
    
    if Trolling.ControlledVehicles[player.id] ~= nil then
        Trolling.ControlledVehicles[player.id].vehicle = vehicle
        Trolling.ControlledVehicles[player.id].clone = clone
    end

    if attached then
        ENTITY.SET_ENTITY_COORDS(clone, vehicle_coords.x, vehicle_coords.y, vehicle_coords.z)
        ENTITY.SET_ENTITY_VELOCITY(clone, vehicle_velocity.x, vehicle_velocity.y, vehicle_velocity.z)
        
        for i = 1, 10 do
            if VEHICLE.GET_PED_IN_VEHICLE_SEAT(clone, -1, false) ~= players.user_ped() then
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), clone, -1)
                util.yield(100)
            end
        end
    else
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Vehicle Control", "Failed to take control of " .. player.name .. "'s vehicle.")
        Trolling.ReturnControlOfVehicle(player)
    end

    return true
end

Trolling.ReturnControlOfVehicle = function(player)
    if Trolling.ControlledVehicles[player.id] == nil then return false end

    local ghost_menu = menu.ref_by_path("Stand>Lua Scripts>" .. SUBFOLDER_NAME .. ">Self>Character...>Ghost Mode")
    if Trolling.ControlledVehicles[player.id].ghost_mode ~= 2 then
        local ghost_mode = if Trolling.ControlledVehicles[player.id].ghost_mode == 1 then "Off" else "Character & Vehicle"
        menu.trigger_command(menu.ref_by_rel_path(ghost_menu, ghost_mode))
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(Trolling.ControlledVehicles[player.id].vehicle) then
        ENTITY.DETACH_ENTITY(Trolling.ControlledVehicles[player.id].vehicle, true, true)
        Objects.SetVehicleDoorsLocked(Trolling.ControlledVehicles[player.id].vehicle, false)
    end
    if ENTITY.IS_ENTITY_A_VEHICLE(Trolling.ControlledVehicles[player.id].clone) then entities.delete_by_handle(Trolling.ControlledVehicles[player.id].clone) end
    if ENTITY.IS_ENTITY_AN_OBJECT(Trolling.ControlledVehicles[player.id].trailer) then entities.delete_by_handle(Trolling.ControlledVehicles[player.id].trailer) end

    Trolling.ControlledVehicles[player.id] = nil
    return true
end

local _vehicle_attachments = {}
local _vehicle_attachment_offsets = {
    [1262567554] = 1.15, -- v_ret_ml_fridge
    [238789712] = 0.25, -- prop_xmas_tree_int
    [-1988908952] = 1, -- prop_air_bigradar
}

Trolling.AttachObjectToVehicle = function(player, object_hash, options)
    local player_to_attach = if type(object_hash) == "number" then Player:Get(object_hash, true) else nil
    if player_to_attach == nil then
        if type(object_hash) == "string" then object_hash = util.joaat(object_hash) end
        if not STREAMING.IS_MODEL_VALID(object_hash) then
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Vehicle Attachments", "The requested object ID does not exist.")
            return
        end
    elseif players.get_vehicle_model(player_to_attach.id) == 0 then
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Vehicle Attachments", player_to_attach.name .. " isn't in a vehicle.")
        return
    elseif options.attach_to == "Wheels" or options.stack_size ~= 1 then
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Vehicle Attachments", "Player vehicles may only be attached to 'Top' or 'Bottom' with a stack size of 1.")
        return
    end

    local user = Player:Self()
    local third_eye = user.id ~= player.id and user.coords:distance(player.coords) > 100
    if third_eye then Ryan.OpenThirdEye(player.coords) end
    
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player.ped_id, true)
    if vehicle == 0 then
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Vehicle Attachments", "Player is not in a vehicle.")
        return
    end
    
    if _vehicle_attachments[player.id] == nil then _vehicle_attachments[player.id] = {} end

    local bones = {}
    local base_x, base_y, base_z, width_x, length_y, height_z = 0, 0, 0, 0, 0, 0
    local is_a_clone = player_to_attach == nil and object_hash == ENTITY.GET_ENTITY_MODEL(vehicle)

    local min, max = v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(if player_to_attach == nil then object_hash else players.get_vehicle_model(player_to_attach.id), min, max)
    height_z = max.z - min.z
    length_y = max.y - min.y

    MISC.GET_MODEL_DIMENSIONS(vehicle, min, max)
    if options.attach_to == "Top" then
        bones[1] = -1
        local vehicle_coords = ENTITY.GET_ENTITY_COORDS(vehicle)
        local raycast_coords = v3(vehicle_coords); raycast_coords:setZ(raycast_coords.z + 9.99)
        local raycast = Ryan.Raycast(raycast_coords, v3(0, 0, -1), 10.01, Ryan.RaycastFlags.Vehicles, true)
        if raycast.did_hit then
            base_z = raycast.hit_coords.z - vehicle_coords.z
        else
            Ryan.Toast("Failed to find the top of the vehicle. Falling back to using model dimensions.")
            base_z = max.z
        end
        if _vehicle_attachment_offsets[object_hash] ~= nil then base_z = base_z + _vehicle_attachment_offsets[object_hash] end
    elseif options.attach_to == "Bottom" then
        bones[1] = -1
        base_z = min.z
        if _vehicle_attachment_offsets[object_hash] ~= nil then base_z = base_z + _vehicle_attachment_offsets[object_hash] end
    elseif options.attach_to == "Wheels" then
        for i = 1, #Objects.VehicleBones.Wheels do
            local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, Objects.VehicleBones.Wheels[i])
            if bone ~= -1 then bones[i] = bone end
        end
    elseif options.attach_to == "Front" then
        bones[1] = -1
        base_y = max.y
    elseif options.attach_to == "Back" then
        bones[1] = -1
        base_y = min.y
        length_y = -length_y
    elseif options.attach_to == "Left Side" then
        bones[1] = -1
        base_x = min.x
    elseif options.attach_to == "Right Side" then
        bones[1] = -1
        base_x = max.x
        width_x = -width_x
    end

    local vehicle_data = if is_a_clone then Objects.GetVehicleData(vehicle) else nil
    Ryan.RequestModel(object_hash)

    local success = false
    for _, bone in pairs(bones) do
        local entity = nil
        for i = 0, options.stack_size - 1 do
            if player_to_attach ~= nil then attachment = PED.GET_VEHICLE_PED_IS_IN(player_to_attach.ped_id)
            elseif STREAMING.IS_MODEL_A_VEHICLE(object_hash) then attachment = entities.create_vehicle(object_hash, ENTITY.GET_ENTITY_COORDS(vehicle), 0)
            elseif STREAMING.IS_MODEL_A_PED(object_hash) then attachment = entities.create_ped(0, object_hash, ENTITY.GET_ENTITY_COORDS(vehicle), 0)
            else attachment = entities.create_object(object_hash, ENTITY.GET_ENTITY_COORDS(vehicle), 0) end

            for attempt = 1, 3 do
                Ryan.Toast("Attempting to attach an object...")
                if Objects.RequestControl(attachment, true) and Objects.RequestControl(vehicle, true) then success = true end

                local x = base_x + (i * (is_a_clone and base_x or width_x))
                local y = base_y + (i * (is_a_clone and base_y or length_y))
                local z = base_z + (i * (is_a_clone and base_z or height_z))
                ENTITY.ATTACH_ENTITY_TO_ENTITY(attachment, vehicle, bone, x, y, z, 0, 0, 0, false, false, options.collision, false, 0, true)
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(attachment, false)
                
                if vehicle_data ~= nil then Objects.SetVehicleData(attachment, vehicle_data) end
                table.insert(_vehicle_attachments[player.id], attachment)
                if success then break end
            end
        end
    end

    if third_eye then Ryan.CloseThirdEye() end
    if success then
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Vehicle Attachments", "Attached " .. (if player_to_attach ~= nil then "a player" else "an object") .. "!")
    else
        Ryan.ShowTextMessage(Ryan.BackgroundColors.Orange, "Vehicle Attachments", "Failed to take control of an entity.")
    end
end

Trolling.DetachObjectsFromVehicle = function(player, delete)
    if _vehicle_attachments[player.id] ~= nil then
        for _, attachment in pairs(_vehicle_attachments[player.id]) do
            if delete then
                entities.delete_by_handle(attachment)
            else
                ENTITY.DETACH_ENTITY(attachment)
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(attachment, true)
            end
        end
    end
    Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Vehicle Attachments", (if delete then "Deleted" else "Detached") .. " all attached objects.")
end

Trolling.WillOrbitalCannonHitEntity = function(coords, entity)
    local entity_coords = ENTITY.GET_ENTITY_COORDS(entity)
    return
        (MISC.GET_DISTANCE_BETWEEN_COORDS(
            coords.x, coords.y, coords.z,
            entity_coords.x, entity_coords.y, entity_coords.z,
            false
        ) < 15)
        and
        (entity_coords.z >= (coords.z - 15))
end

-- Orbital cannon code stolen straight from R* themselves :D
Trolling.FireOrbitalCannon = function(coords, camera)
    local ground_z = memory.alloc()
    MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, coords.z, ground_z, false, false)
    coords:setZ(memory.read_float(ground_z))

    function explode(explosion_coords)
        FIRE.ADD_OWNED_EXPLOSION(
            players.user_ped(),
            explosion_coords.x, explosion_coords.y, explosion_coords.z,
            59, 1, true, false, 1
        )
    end

    for _, player in pairs(Player:List(true, true, true)) do
        if Trolling.WillOrbitalCannonHitEntity(coords, player.ped_id) then
            explode(player.coords)
        end
    end

    for _, vehicle in pairs(Objects.GetAllNearCoords(coords, 30, Objects.Type.Vehicle)) do
        if Trolling.WillOrbitalCannonHitEntity(coords, vehicle) then
            explode(ENTITY.GET_ENTITY_COORDS(vehicle))
        end
    end

    explode(coords)

    PTFX.PlayAtCoords(coords, "scr_xm_orbital", "scr_xm_orbital_blast", {r = 1.0, g = 1.0, b = 1.0})
    Ryan.PlaySoundAtCoords(coords, 0, "DLC_XM_Explosions_Orbital_Cannon", 0)

    if camera ~= nil then
        CAM.SHAKE_CAM(camera, "GAMEPLAY_EXPLOSION_SHAKE", 1.5)
        PAD.SET_PAD_SHAKE(0, 500, 256)
    end
end