Objects = {}

--========================= Generic Objects =========================--
-- Entity types to include.
Objects.Type = {
    All = 1,
    Ped = 2,
    Vehicle = 3
}

-- Get all entities of type within range of the specified coordinates.
Objects.GetAllNearCoords = function(coords, range, types, include_own_vehicle)
    if include_own_vehicle == nil then include_own_vehicle = true end
    local player_vehicle = GET_VEHICLE_PED_IS_IN(players.user_ped())
    local nearby_objects = {}

    if types == Objects.Type.Ped or types == Objects.Type.All then
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if ped ~= players.user_ped() then
                local ped_coords = GET_ENTITY_COORDS(ped)
                if coords:distance(ped_coords) <= range then
                    table.insert(nearby_objects, ped)
                end
            end
        end
    end

    if types == Objects.Type.Vehicle or types == Objects.Type.All then
        for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
            if include_own_vehicle or players.get_vehicle_model(players.user()) == 0 or vehicle ~= GET_VEHICLE_PED_IS_IN(players.user_ped()) then
                local vehicle_coords = GET_ENTITY_COORDS(vehicle)
                if coords:distance(vehicle_coords) <= range then
                    table.insert(nearby_objects, vehicle)
                end
            end
        end
    end

    table.sort(nearby_objects, function(object_1, object_2)
        return coords:distance(GET_ENTITY_COORDS(object_1)) < coords:distance(GET_ENTITY_COORDS(object_2))
    end)
    
    return nearby_objects
end

-- Request control of an entity, optionally wait until it has been received.
Objects.RequestControl = function(entity, loop)
    local network_id = NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    if loop then
        local starting_time = util.current_time_millis()
        while not NETWORK_HAS_CONTROL_OF_ENTITY(entity) and util.current_time_millis() - starting_time < 1000 do
            util.yield()
            SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
            NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        end
    else
        if not NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
            SET_NETWORK_ID_CAN_MIGRATE(network_id, true)
            NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        end
    end
    return NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

-- Draw an ESP box around an entity.
Objects.DrawESP = function(entity)
    if Ryan.HUDUseBeacon then
        Ryan.DrawBeacon(GET_ENTITY_COORDS(entity))
        return
    end

    if DOES_ENTITY_EXIST(entity) then
        local minimum, maximum = v3.new(), v3.new()
        GET_MODEL_DIMENSIONS(GET_ENTITY_MODEL(entity), minimum, maximum)

        local width  = 2 * maximum.x
        local length = 2 * maximum.y
        local depth  = 2 * maximum.z

        local offsets = {
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2,  depth / 2),
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2,  depth / 2),
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2,  depth / 2),
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2,  depth / 2),
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2, -depth / 2),
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2, -depth / 2),
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2, -depth / 2),
            GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2, -depth / 2)
        }

        local color = {r = math.floor(Ryan.HUDColor.r * 255), g = math.floor(Ryan.HUDColor.g * 255), b = math.floor(Ryan.HUDColor.b * 255)}
        DRAW_LINE(offsets[1].x, offsets[1].y, offsets[1].z, offsets[4].x, offsets[4].y, offsets[4].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[1].x, offsets[1].y, offsets[1].z, offsets[2].x, offsets[2].y, offsets[2].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[1].x, offsets[1].y, offsets[1].z, offsets[5].x, offsets[5].y, offsets[5].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[2].x, offsets[2].y, offsets[2].z, offsets[3].x, offsets[3].y, offsets[3].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[3].x, offsets[3].y, offsets[3].z, offsets[8].x, offsets[8].y, offsets[8].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[4].x, offsets[4].y, offsets[4].z, offsets[7].x, offsets[7].y, offsets[7].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[4].x, offsets[4].y, offsets[4].z, offsets[3].x, offsets[3].y, offsets[3].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[5].x, offsets[5].y, offsets[5].z, offsets[7].x, offsets[7].y, offsets[7].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[6].x, offsets[6].y, offsets[6].z, offsets[2].x, offsets[2].y, offsets[2].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[6].x, offsets[6].y, offsets[6].z, offsets[8].x, offsets[8].y, offsets[8].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[5].x, offsets[5].y, offsets[5].z, offsets[6].x, offsets[6].y, offsets[6].z, color.r, color.g, color.b, 255)
        DRAW_LINE(offsets[7].x, offsets[7].y, offsets[7].z, offsets[8].x, offsets[8].y, offsets[8].z, color.r, color.g, color.b, 255)
    end
end

-- Add spotlights to an entity at the specific offset and intensity.
_spotlights = {}

Objects.AddSpotlight = function(entity, offset, intensity)
    if IS_ENTITY_A_VEHICLE(entity) then
        for i = 1, #Ryan.Haulers do
            if IS_VEHICLE_MODEL(entity, Ryan.Haulers[i]) then
                local trailer_ptr = memory.alloc_int()
                GET_VEHICLE_TRAILER_VEHICLE(entity, trailer_ptr)
                local trailer = memory.read_int(trailer_ptr)
                if trailer ~= 0 then
                    Objects.AddSpotlight(trailer, offset, intensity)
                    return
                else
                    break
                end
            end
        end
    end

    local coords = GET_ENTITY_COORDS(entity)
    local model = GET_ENTITY_MODEL(entity)

    local minimum, maximum = v3.new(), v3.new()
    GET_MODEL_DIMENSIONS(model, minimum, maximum)

    local wall_light = util.joaat("prop_wall_light_15a")
    if _spotlights[entity] ~= nil then
        Objects.DetachAll(entity)
    end

    for i = 1, intensity do
        _spotlights[entity] = true

        local offsets = {
            {x = 0.0, y = 0.0, z = (maximum.z * offset - 0.5)},
            {x = 0.0, y = 0.0, z = (-maximum.z * offset - 0.5)},
            {x = 0.0, y = (maximum.y * offset * 0.66), z = -0.5},
            {x = 0.0, y = (-maximum.y * offset * 0.66), z = -0.5},
            {x = (maximum.x * offset), y = 0.0, z = -0.5},
            {x = (-maximum.x * offset), y = 0.0, z = -0.5}
        }
        for i = 1, #offsets do
            local coords = v3(coords.x + offsets[i].x, coords.y + offsets[i].y, coords.z + offsets[i].z)
            local light = entities.create_object(wall_light, coords)
            local rotation = GET_ENTITY_COORDS(entity):lookAt(coords)
            ATTACH_ENTITY_TO_ENTITY(light, entity, 0, offsets[i].x, offsets[i].y, offsets[i].z, rotation.x, rotation.y, rotation.z, false, false, false, false, 0, true)
        end
    end
end

-- Detach all other entities from an entity.
Objects.DetachAll = function(entity)
    local objects = entities.get_all_objects_as_handles()
    for _, object in pairs(objects) do
        if IS_ENTITY_ATTACHED_TO_ENTITY(object, entity) then
            Objects.RequestControl(object, true)
            DETACH_ENTITY(object, false, false)
            util.yield()
            entities.delete_by_handle(object)
        end
    end
end

Objects.Catapult = function(object)
    APPLY_FORCE_TO_ENTITY(object, 1, 0.0, 0.0, 9999, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
end

Objects.PlayerBones = {
    Head = {"IK_Head"},
    Hands = {"IK_L_Hand", "IK_R_Hand"},
    Pointer = {"IK_L_Hand"},
    Feet = {"IK_L_Foot", "IK_R_Foot"}
}
    
Objects.VehicleBones = {
    Wheels = {"wheel_lf", "wheel_lr", "wheel_rf", "wheel_rr"},
    Exhaust = {"exhaust", "exhaust_2", "exhaust_3", "exhaust_4", "exhaust_5", "exhaust_6", "exhaust_7", "exhaust_8"}
}
    
Objects.WeaponBones = {
    Muzzle = {"gun_vfx_eject"}
}

--========================= Vehicles =========================--
Objects.VehicleModChoices = {
    [0] = "Spoilers",
    [1] = "Front Bumper",
    [2] = "Rear Bumper",
    [3] = "Side Skirt",
    [4] = "Exhaust",
    [5] = "Frame",
    [6] = "Grille",
    [7] = "Hood",
    [8] = "Fender",
    [9] = "Right Fender",
    [10] = "Roof",
    [11] = "Engine",
    [12] = "Brakes",
    [13] = "Transmission",
    [14] = "Horns",
    [15] = "Suspension",
    [16] = "Armor",
    [23] = "Wheels Design",
    [24] = "Motorcycle Back Wheel Design",
    [25] = "Plate Holders",
    [27] = "Trim Design",
    [28] = "Ornaments",
    [30] = "Dial Design",
    [33] = "Steering Wheel",
    [34] = "Shifter Leavers",
    [35] = "Plaques",
    [38] = "Hydraulics",
    [48] = "Livery"
}
Objects.VehicleModToggles = {
    [17] = "UNK17",
    [18] = "Turbo Turning",
    [19] = "UNK19",
    [20] = "Tire Smoke",
    [21] = "UNK21",
    [22] = "Xenon Headlights"
}

Objects.VehicleSpeed = {
    Normal = 0,
    Fast = 1,
    Slow = 2
}

Objects.SetVehicleFullyUpgraded = function(vehicle, fully_upgraded)
    SET_VEHICLE_MOD_KIT(vehicle, 0)
    for i = 0, 50 do
        local mod = -1
        if fully_upgraded then mod = GET_NUM_VEHICLE_MODS(vehicle, i) - 1 end
        SET_VEHICLE_MOD(vehicle, i, mod, fully_upgraded)
    end
end

Objects.SetVehicleSpeed = function(vehicle, speed)
    if IS_ENTITY_A_VEHICLE(vehicle) then
        if speed == Objects.VehicleSpeed.Normal then
            MODIFY_VEHICLE_TOP_SPEED(vehicle, -1.0)
            SET_ENTITY_MAX_SPEED(vehicle, 64)
        else
            MODIFY_VEHICLE_TOP_SPEED(vehicle, if speed == Objects.VehicleSpeed.Fast then 1000000 else 2)
            SET_ENTITY_MAX_SPEED(vehicle, if speed == Objects.VehicleSpeed.Fast then 64 else 1)
        end
    end
end

Objects.SetVehicleHasGrip = function(vehicle, grip)
    -- TODO
    SET_VEHICLE_REDUCE_GRIP(vehicle, not grip)
    if not grip then SET_DRIFT_TYRES(vehicle, false) end -- ?
end

Objects.SetVehicleDoorsLocked = function(vehicle, doors_locked)
    SET_VEHICLE_DOORS_LOCKED(vehicle, if doors_locked then 4 else 0)
end

Objects.SetVehicleTiresBursted = function(vehicle, tires_bursted)
    if tires_bursted then SET_VEHICLE_TYRES_CAN_BURST(vehicle, true) end
    for tire = 0, 7 do
        if tires_bursted then
            if not IS_VEHICLE_TYRE_BURST(vehicle, tire, true) then
                SET_VEHICLE_TYRE_BURST(vehicle, tire, tires_bursted, 1000.0)
            end
        else
            SET_VEHICLE_TYRE_FIXED(vehicle, tire)
        end
    end
end

Objects.StealVehicle = function(vehicle)
    if vehicle ~= 0 then
        local driver = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        local failed_to_kick = false
        local start_time = util.current_time_millis()

        local driver_player_id = nil
        if driver ~= 0 and IS_PED_A_PLAYER(driver) then
            for _, player_id in pairs(players.list()) do
                if Player:Get(player_id).ped_id == driver then
                    driver_player_id = player_id
                end
            end
        end

        if driver_player_id ~= nil then
            Ryan.ShowTextMessage(Ryan.BackgroundColors.Purple, "Steal Vehicle", "Stealing the vehicle...")
            menu.trigger_commands("vehkick" .. players.get_name(driver_player_id))
        elseif driver ~= 0 then
            entities.delete_by_handle(driver)
        end
        
        while driver ~= 0 and GET_PED_IN_VEHICLE_SEAT(vehicle, -1) == driver do
            if util.current_time_millis() - start_time > 10000 then
                Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Steal Vehicle", "Failed to kick the driver of the vehicle.")
                failed_to_kick = true
                break
            end
            util.yield()
        end
        if not failed_to_kick then
            SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
        end
    end
end

-- TODO - crashes
Objects.MakeVehicleBlind = function(vehicle)
    local driver = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
    local coords = GET_ENTITY_COORDS(vehicle)
    coords:add(math.random(-500, 500), math.random(-500, 500), 0)
    SET_DRIVER_AGGRESSIVENESS(driver, 1.0)
    TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(driver, vehicle, coords.x, coords.y, coords.z, 150.0, 524800, 20.0)

    --TASK_VEHICLE_DRIVE_WANDER(driver, vehicle, 10.0, 4719104)
    --GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, coords.z, ground_z, false)
end

Objects.GetVehicleData = function(vehicle)
    local data = {model = GET_ENTITY_MODEL(vehicle)}
    local r, g, b, color = memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int()

    data.colors = {primary = {}, secondary = {}}

    -- Base Color
    local primary, secondary = memory.alloc_int(), memory.alloc_int()
    GET_VEHICLE_COLOURS(vehicle, primary, secondary)
    data.colors.primary.base, data.colors.secondary.base = memory.read_int(primary), memory.read_int(secondary)

    -- Primary Color
    if GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(vehicle) then
        GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, r, g, b)
        data.colors.primary.custom = {r = memory.read_int(r), b = memory.read_int(g), g = memory.read_int(b)}
    else
        local type, color, pearlescent = memory.alloc_int(), memory.alloc_int(), memory.alloc_int()
        GET_VEHICLE_MOD_COLOR_1(vehicle, type, color, pearlescent)
        data.colors.primary.type, data.colors.primary.color, data.colors.primary.pearlescent = memory.read_int(type), memory.read_int(color), memory.read_int(pearlescent)
    end

    -- Secondary Color
    if GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(vehicle) then
        GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, r, g, b)
        data.colors.secondary.custom = {r = memory.read_int(r), b = memory.read_int(g), g = memory.read_int(b)}
    else
        local type, color = memory.alloc_int(), memory.alloc_int()
        GET_VEHICLE_MOD_COLOR_2(vehicle, type, color)
        data.colors.secondary.type, data.colors.secondary.color = memory.read_int(type), memory.read_int(color)
    end

    -- Pearlescent & Wheel Color
    local pearlescent, wheel = memory.alloc_int(), memory.alloc_int()
    GET_VEHICLE_EXTRA_COLOURS(vehicle, pearlescent, wheel)
    data.extra_colors = {pearlescent = memory.read_int(pearlescent), wheel = memory.read_int(wheel)}

    -- Tire Smoke Color
    GET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, r, g, b)
    data.tire_smoke_color = {r = memory.read_int(r), g = memory.read_int(g), b = memory.read_int(b)}

    -- Dashboard Color
    GET_VEHICLE_EXTRA_COLOUR_5(vehicle, color)
    data.dashboard_color = memory.read_int(color)

    -- Interior Color
    GET_VEHICLE_EXTRA_COLOUR_6(vehicle, color)
    data.interior_color = memory.read_int(color)

    -- Mods
    data.mod_choices = {}
    for id, name in pairs(Objects.VehicleModChoices) do
        data.mod_choices[id] = GET_VEHICLE_MOD(vehicle, id)
    end

    data.mod_toggles = {}
    for id, name in pairs(Objects.VehicleModToggles) do
        data.mod_toggles[id] = IS_TOGGLE_MOD_ON(vehicle, id)
    end

    data.mod_extras = {}
    for i = 1, 14 do
        if DOES_EXTRA_EXIST(vehicle, i) then
            data.mod_extras[i] = IS_VEHICLE_EXTRA_TURNED_ON(vehicle, i)
        end
    end

    -- Neon
    GET_VEHICLE_NEON_COLOUR(vehicle, r, g, b)
    data.neon = {
        enabled = {
            left = GET_VEHICLE_NEON_ENABLED(vehicle, 0),
            right = GET_VEHICLE_NEON_ENABLED(vehicle, 1),
            front = GET_VEHICLE_NEON_ENABLED(vehicle, 2),
            back = GET_VEHICLE_NEON_ENABLED(vehicle, 3)
        },
        color = {r = memory.read_int(r), g = memory.read_int(g), b = memory.read_int(b)}
    }

    -- License Plate
    data.license_plate = {
        type = GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle),
        text = GET_VEHICLE_NUMBER_PLATE_TEXT(vehicle)
    }

    -- Miscellaneous
    data.livery = GET_VEHICLE_LIVERY(vehicle)
    data.window_tint = GET_VEHICLE_WINDOW_TINT(vehicle)
    data.xenon_color = GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle)
    data.dirt_level = GET_VEHICLE_DIRT_LEVEL(vehicle)
    data.has_bulletproof_tires = not GET_VEHICLE_TYRES_CAN_BURST(vehicle)
    data.is_engine_on = GET_IS_VEHICLE_ENGINE_RUNNING(vehicle)
    data.is_siren_on = IS_VEHICLE_SIREN_ON(vehicle)

    return data
end

Objects.SetVehicleData = function(vehicle, data)
    SET_VEHICLE_MOD_KIT(vehicle, 0)

    -- Base Color
    SET_VEHICLE_COLOURS(vehicle, data.colors.primary.base, data.colors.secondary.base)

    -- Primary Color
    if data.colors.primary.custom ~= nil then
        SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, data.colors.primary.custom.r, data.colors.primary.custom.b, data.colors.primary.custom.g)
    else
        SET_VEHICLE_MOD_COLOR_1(vehicle, data.colors.secondary.type, data.colors.secondary.color, data.colors.secondary.pearlescent)
    end

    -- Secondary Color
    if data.colors.secondary.custom then
        SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, data.colors.secondary.r, data.colors.secondary.b, data.colors.secondary.g)
    else
        SET_VEHICLE_MOD_COLOR_2(vehicle, data.colors.secondary.type, data.colors.secondary.color)
    end

    -- Pearlescent & Wheel Color
    SET_VEHICLE_EXTRA_COLOURS(vehicle, data.extra_colors.pearlescent, data.extra_colors.wheel)

    -- Tire Smoke Color
    SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, data.tire_smoke_color.r, data.tire_smoke_color.g, data.tire_smoke_color.b)

    -- Dashboard Color
    SET_VEHICLE_EXTRA_COLOUR_6(vehicle, data.dashboard_color)

    -- Interior Color
    SET_VEHICLE_EXTRA_COLOUR_5(vehicle, data.interior_color)

    -- Mods
    for id, name in pairs(Objects.VehicleModChoices) do
        if data.mod_choices[id] then
            SET_VEHICLE_MOD(vehicle, id, data.mod_choices[id])
        end
    end

    for id, name in pairs(Objects.VehicleModToggles) do
        TOGGLE_VEHICLE_MOD(vehicle, id, data.mod_toggles[id])
    end

    for i = 1, 14 do
        SET_VEHICLE_EXTRA(vehicle, i, if data.mod_extras[i] ~= nil then (not data.mod_extras[i]) else true)
    end

    -- Neon
    SET_VEHICLE_NEON_COLOUR(vehicle, data.neon.color.r, data.neon.color.g, data.neon.color.b)
    SET_VEHICLE_NEON_ENABLED(vehicle, 0, data.neon.enabled.left)
    SET_VEHICLE_NEON_ENABLED(vehicle, 1, data.neon.enabled.right)
    SET_VEHICLE_NEON_ENABLED(vehicle, 2, data.neon.enabled.front)
    SET_VEHICLE_NEON_ENABLED(vehicle, 3, data.neon.enabled.back)

    -- License Plate
    SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, data.license_plate.text)
    SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, data.license_plate.type)

    -- Miscellaneous
    SET_VEHICLE_LIVERY(vehicle, data.livery)
    SET_VEHICLE_WINDOW_TINT(vehicle, data.window_tint)
    SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, data.xenon_color)
    SET_VEHICLE_DIRT_LEVEL(vehicle, data.dirt_level)
    SET_VEHICLE_TYRES_CAN_BURST(vehicle, data.has_bulletproof_tires)
    SET_VEHICLE_ENGINE_ON(vehicle, data.is_engine_on, true, false)
    SET_VEHICLE_SIREN(vehicle, data.is_siren_on)
end

Objects.GetPedData = function(ped)
    local data = {
        model = GET_ENTITY_MODEL(ped),
        components = {}
    }

    for id = 0, 11 do
        data.components[id] = {
            drawable = GET_PED_DRAWABLE_VARIATION(ped, id),
            texture = GET_PED_TEXTURE_VARIATION(ped, id),
            palette = GET_PED_PALETTE_VARIATION(ped, id)
        }
    end

    return data
end

Objects.SetPedData = function(ped, data)
    for id, component in pairs(data.components) do
        SET_PED_COMPONENT_VARIATION(ped, id, component.drawable, component.texture, component.palette)
    end
end