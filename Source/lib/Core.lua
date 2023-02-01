local _waiting_for_session = false
local _waiting_for_coords = nil

Ryan.GhostMode = 1
Ryan.FriendSpoofsFile = filesystem.store_dir() .. SUBFOLDER_NAME .. "\\FriendSpoofs.json"

-- Initialize globals.
Ryan.Init = function()
    Ryan.LogoTexture = directx.create_texture(filesystem.resources_dir() .. SUBFOLDER_NAME .. "\\Logo.png")
    Ryan.CrosshairTexture = directx.create_texture(filesystem.resources_dir() .. SUBFOLDER_NAME .. "\\Crosshair.png")
    Ryan.RequestModel(util.joaat("p_poly_bag_01_s"))
	if not filesystem.exists(filesystem.store_dir() .. SUBFOLDER_NAME) then
		filesystem.mkdirs(filesystem.store_dir() .. SUBFOLDER_NAME)
	end
	if not filesystem.exists(Ryan.FriendSpoofsFile) then
		Ryan.WriteJSON(Ryan.FriendSpoofsFile, {})
	end
end

Ryan.ReadJSON = function(file)
	local destination = assert(io.open(file, "r"))
	local contents = destination:read("*a")
	assert(destination:close())
	return JSON.Decode(contents)
end

Ryan.WriteJSON = function(file, contents)
	local destination = assert(io.open(file, "w"))
	destination:write(JSON.Encode(contents))
	assert(destination:close())
end

Ryan.FriendSpoofs = {}

-- HUD settings.
Ryan.HUDColor = {r = 0.29, g = 0.69, b = 1.0}
Ryan.HUDUseBeacon = false
Ryan.TextKeybinds = false

-- Background colors for certain UI elements.
Ryan.BackgroundColors = {
    Black      = 2,
    Gray       = 5,
    Blue       = 9,
    Orange     = 15,
    Pink       = 24,
    Green      = 25,
    Red        = 27,
    LightPink  = 30,
    Teal       = 37,
    Tan        = 38,
    LightGreen = 46,
    Navy       = 47,
    Purple     = 49,
    Yellow     = 50,
}

-- Input control IDs.
Ryan.Controls = {
    CharacterWheel          = 19,  -- Alt
    MultiplayerInfo         = 20,  -- Z
    Sprint                  = 21,  -- Shift
    Enter                   = 23,  -- F
    LookBehind              = 26,  -- C
	SpecialAbilitySecondary = 29, -- B
	SelectWeapon            = 37,  -- Tab
    Cover                   = 44,  -- Q
    Reload                  = 45,  -- R
    HudSpecial              = 48,  -- Z
	VehicleAim              = 68,  -- Right Mouse
	VehicleAttack           = 69,  -- Left Mouse
    VehicleDuck             = 73,  -- X
    VehicleExit             = 75,  -- F
    VehicleLookBehind       = 79,  -- C
    VehicleCinematicCamera  = 80,  -- R
    VehicleRadioWheel       = 85,  -- Q
    VehicleHorn             = 86,  -- E
    MeleeAttackLight        = 140, -- R
    SelectWeaponUnarmed     = 157, -- 1
    SelectWeaponMelee       = 158, -- 2
    SelectWeaponShotgun     = 160, -- 3
    SelectWeaponHeavy       = 164, -- 4
    SelectWeaponSpecial     = 165, -- 5
}

-- Translation languages.
Ryan.Languages = {
    {"Spanish", "ES", false},
    {"Portugese", "PT", false},
    {"French", "FR", false},
    {"Italian", "IT", false},
    {"German", "DE", false},
    {"Chinese", "ZH", false},
    {"Russian", "RU", false},
}

-- Cyrillic/Latin transliteration table.
Ryan.CyrillicAlphabet = {
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

-- Action Figure coordinates.
Ryan.ActionFigures = {
    {3514, 3754, 35}, {3799, 4473, 7}, {3306, 5194, 18}, {2937, 4620, 48}, {2725, 4142, 44},
    {2487, 3759, 43}, {1886, 3913, 33}, {1702, 3290, 48}, {1390, 3608, 34}, {1298, 4306, 37},
    {1714, 4791, 41}, {2416, 4994, 46}, {2221, 5612, 55}, {1540, 6323, 24}, {1310, 6545, 5},
    {457, 5573, 781}, {178, 6394, 31}, {-312, 6314, 32}, {-689, 5829, 17}, {-552, 5330, 75},
    {-263, 4729, 138}, {-1121, 4977, 186}, {-2169, 5192, 17}, {-2186, 4250, 48}, {-2172, 3441, 31},
    {-1649, 3018, 32}, {-1281, 2550, 18}, {-1514, 1517, 111}, {-1895, 2043, 142}, {-2558, 2316, 33},
    {-3244, 996, 13}, {-2959, 386, 14}, {-3020, 41, 10}, {-2238, 249, 176}, {-1807, 427, 132},
    {-1502, 813, 181}, {-770, 877, 204}, {-507, 393, 97}, {-487, -55, 39}, {-294, -343, 10},
    {-180, -632, 49}, {-108, -857, 39}, {-710, -906, 19}, {-909, -1149, 2}, {-1213, -960, 1},
    {-1051, -523, 36},{-989, -102, 40}, {-1024, 190, 62}, {-1462, 182, 55}, {-1720, -234, 55},
    {-1547, -449, 40}, {-1905, -710, 8}, {-1648, -1095, 13}, {-1351, -1547, 4}, {-887, -2097, 9},
    {-929, -2939, 13}, {153, -3078, 7}, {483, -3111, 6}, {-56, -2521, 7}, {368, -2114, 17},
    {875, -2165, 32}, {1244, -2573, 43}, {1498, -2134, 76}, {1207, -1480, 34}, {679, -1523, 9},
    {379, -1510, 29}, {-44, -1749, 29}, {-66, -1453, 32}, {173, -1209, 30}, {657, -1047, 22},
    {462, -766, 27}, {171, -564, 22}, {621, -410, -1}, {1136, -667, 57}, {988, -138, 73},
    {1667, 0, 166}, {2500, -390, 95}, {2549, 385, 108}, {2618, 1692, 31}, {1414, 1162, 114},
    {693, 1201, 345}, {660, 549, 130}, {219, 97, 97}, {-141, 234, 99}, {87, 812, 211},
    {-91, 939, 233}, {-441, 1596, 358}, {-58, 1939, 190}, {-601, 2088, 132}, {-300, 2847, 55},
    {63, 3683, 39}, {543, 3074, 40}, {387, 2570, 44}, {852, 2166, 52}, {1408, 2157, 98},
    {1189, 2641, 38}, {1848, 2700, 63}, {2635, 2931, 44}, {2399, 3063, 54}, {2394, 3062, 52}
}

-- Signal Jammer coordinates.
Ryan.SignalJammers = {
    {-3096, 783, 33}, {-2273, 325, 195}, {-1280, 304, 91}, {-1310, -445, 108}, {-1226, -866, 82},
    {-1648, -1125, 29}, {-686, -1381, 24}, {-265, -1897, 54}, {-988, -2647, 89}, {-250, -2390, 124},
    {554, -2244, 74}, {978, -2881, 33}, {1586, -2245, 130}, {1110, -1542, 55}, {405, -1387, 75},
    {-1, -1018, 95}, {-182, -589, 210}, {-541, -213, 82}, {-682, 228, 154}, {-421, 1142, 339},
    {-296, 2839, 68}, {753, 2596, 133}, {1234, 1869, 92}, {760, 1263, 444}, {677, 556, 153},
    {220, 224, 168}, {485, -109, 136}, {781, -705, 47}, {1641, -33, 178}, {2442, -383, 112},
    {2580, 444, 115}, {2721, 1519, 85}, {2103, 1754, 138}, {1709, 2658, 60}, {1859, 3730, 116},
    {2767, 3468, 67}, {3544, 3686, 60}, {2895, 4332, 101}, {3296, 5159, 29}, {2793, 5984, 366},
    {1595, 6431, 32}, {-119, 6217, 62}, {449, 5595, 793}, {1736, 4821, 60}, {732, 4099, 37},
    {-492, 4428, 86}, {-1018, 4855, 301}, {-2206, 4299, 54}, {-2367, 3233, 103}, {-1870, 2069, 154}
}

-- Playing Card coordinates.
Ryan.PlayingCards = {
    {-1028, -2747, 14}, {-74, -2005, 18}, {202, -1645, 29}, {120, -1298, 29}, {11, -1102, 29},
    {-539, -1279, 27}, {-1205, -1560, 4}, {-1288, -1119, 7}, {-1841, -1235, 13}, {-1155, -528, 31},
    {-1167, -234, 37}, {-971, 104, 55}, {-1513, -105, 54}, {-3048, 585, 7}, {-3150, 1115, 20},
    {-1829, 798, 138}, {-430, 1214, 325}, {-409, 585, 125}, {-103, 368, 112}, {253, 215, 106},
    {-168, -298, 40}, {183, -686, 43}, {1131, -983, 46}, {1159, -317, 69}, {548, -190, 54},
    {1487, 1128, 114}, {730, 2514, 73}, {188, 3075, 43}, {-288, 2545, 75}, {-1103, 2714, 19},
    {-2306, 3388, 31}, {-1583, 5204, 4}, {-749, 5599, 41}, {-283, 6225, 31}, {99, 6620, 32},
    {1876, 6410, 46}, {2938, 5325, 101}, {3688, 4569, 25}, {2694, 4324, 45}, {2120, 4784, 40},
    {1707, 4920, 42}, {727, 4189, 41}, {-524, 4193, 193}, {79, 3704, 41}, {900, 3557, 33},
    {1690, 3588, 35}, {1991, 3045, 47}, {2747, 3465, 55}, {2341, 2571, 47}, {2565, 297, 108},
    {1325, -1652, 52}, {989, -1801, 31}, {827, -2159, 29}, {810, -2979, 6}
}

-- Movie Prop coordinates.
Ryan.MovieProps = {
    {94, -1293, 29}, {-1010, -501, 38}, {2517, 3789, 54}, {-2348, 3270, 33},
    {-41, 2873, 60}, {-1169, 4926, 224}, {1165.2252, 248.03876, -51}
}

-- The Slasher's clue coordinates.
Ryan.SlasherClues = {
    {-135.03899, 1912.0951, 197.3230}, {1113.9885, 3142.3547, 38.558643},
    {1904.079, 4911.179, 48.846428}, {-680.2069, 5798.918, 17.33097}
}

-- The Slasher's van coordinates.
Ryan.SlasherVans = {
    {2436.439, 5842.429, 58.72461}, {2896.4573, 3674.395, 45.182766},
    {2569.6438, 1259.2722, 44.39878}, {-1551.7269, 4404.269, 6.6305246},
    {-1710.8304, 2621.2546, 3}
}

-- The Slasher's final event coordinates.
Ryan.SlasherFinale = {
    1320.2701, 3140.9683, 40.42251
}

-- Treasure Hunt coordinates.
Ryan.Treasures = {
    {-1913.0719, 1388.7817, 219.14182}, {1924.326, 3986.48, 32.19},
    {1994.7795, 5078.7495, 42.685287}
}

-- USB Music Stick coordinates.
Ryan.USBSticks = {
    {-2172.587, 1159.6364, -24.372166}, {2725.424, -382.7012, -48.97467},
    {-1618.6365, -3010.6003, -75.205}, {955.64325, 49.459408, 112.55278}
}

-- Vehicle bones useful for attaching to.
VehicleAttachBones = {
    {"Center", nil},
    {"Hood", "bonnet"},
    {"Windshield", "windscreen"},
    {"License Plate", "numberplate"},
    {"Exhaust", "exhaust"},
    {"Trunk", "boot"}
}

-- Forcefield types.
Ryan.ForcefieldTypes = {"Off", "Push", "Pull", "Spin", "Up", "Down", "Smash", "Chaos", "Explode"}

-- God Finger force types.
Ryan.GodFingerForces = {"Default", "Push", "Pull", "Spin", "Up", "Down", "Smash", "Chaos", "Explode"}

-- Anti-hermit punishment modes.
Ryan.AntihermitModes = {"Off", "Teleport Outside", "Kick", "Crash"}

-- NPC scenario types.
Ryan.NPCScenarios = {"Off", "Musician", "Human Statue", "Paparazzi", "Janitor", "Nude", "Delete"}

-- Coordinates for the best earrape known to man.
Ryan.BedSoundCoords = {
    {x = -73.31681060791, y = -820.26013183594, z = 326.17517089844},
    {x = 2784.536, y = 5994.213, z = 354.275},
    {x = -983.292, y = -2636.995, z = 89.524},
    {x = 1747.518, y = 4814.711, z = 41.666},
    {x = 1625.209, y = -76.936, z = 166.651},
    {x = 751.179, y = 1245.13, z = 353.832},
    {x = -1644.193, y = -1114.271, z = 13.029},
    {x = 462.795, y = 5602.036, z = 781.400},
    {x = -125.284, y = 6204.561, z = 40.164},
    {x = 2099.765, y = 1766.219, z = 102.698}
}

-- Hashes of ped models and groups.
Ryan.PedGroups = {
    LawEnforcement = {6, 27, 29}
}
Ryan.PedModels = {
    CayoPericoHeist = {1821116645, 193469166, 2127932792},
    CasinoHeist = {-1094177627, 337826907},
    DoomsdayHeist = {-1275859404, 1650288984, 2618542997, 2431602996}
}

-- Hashes of vehicles.
Ryan.Haulers = {
    1518533038, 387748548, 371926404, -1649536104, 177270108
}
Ryan.PoliceVehicles = {
	1127131465, -1647941228, 2046537925, -1627000575,
	1912215274, -1973172295, -1536924937, -1779120616,
	456714581, -34623805, 353883353, 741586030,
	-488123221, -1205689942, -1683328900, 1922257928
}

-- Ped task IDs.
Ryan.Tasks = {
    ["ExitVehicle"] = 2,
    ["EnterVehicle"] = 160
}

-- Better toasts.
Ryan.Toast = function(...)
    local args = { count = select("#", ...); ... }
	local toast = ""
	for i = 1, args.count do
		if args[i] == nil then toast = toast .. "[undefined]\n"
		elseif type(args[i]) == 'number' or type(object) == 'boolean' or type(args[i]) == 'string' then toast = toast .. args[i] .. "\n"
		elseif args[i].id and args[i].name then toast = toast .. "p(" .. args[i].name .. ")\n"
		elseif args[i].x and args[i].y and args[i].z then toast = toast .. "v3(" .. args[i].x .. ", " .. args[i].y .. ", " .. args[i].z .. ")\n"
		else toast = toast .. "[" .. type(args[i]) .. "]\n" end
	end
	if toast:len() > 0 then toast = toast:sub(1, -2) end
	util.toast(toast)
end

-- Download the latest version if a new one is available, or if force == true.
Ryan.CheckForUpdates = function(force)
	if DEV_ENVIRONMENT then show_intro("Version " .. VERSION .. (if DEV_ENVIRONMENT then " (Dev)" else ""), util.current_time_millis()) end

	if not DEV_ENVIRONMENT or force then
		local updating = 1

		async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/MANIFEST", function(manifest)
			latest_version = manifest:sub(1, manifest:find("\n") - 1)
			manifest = JSON.Decode(manifest:sub(manifest:find("\n"), manifest:len()))
			
			if latest_version ~= VERSION or force then
				updating = 2
				show_intro("Updating...", -1)

				-- -- Download Update
				local files_total, files_done = 0, 0
				for directory, files in pairs(manifest) do
					files_total = files_total + (if directory == "main" then 1 else #files)
				end

				function on_update()
					util.show_corner_help("Please restart Ryan's Menu to start using version " .. latest_version .. ".")
					--Ryan.ShowTextMessage(49, "Auto-Update", "Updated! Please restart Ryan's Menu to continue.")
					menu.focus(menu.ref_by_command_name("stopluaryansmenu"))
					util.stop_script()
				end

				for directory, files in pairs(manifest) do
					if directory == "main" then
						async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/Source/" .. files, function(contents)
							if DEV_ENVIRONMENT then
								Ryan.Toast("Saved a file.")
							else
								local destination = assert(io.open(filesystem.scripts_dir() .. files, "w"))
								destination:write(contents)
								assert(destination:close())
							end
							files_done = files_done + 1
							if files_done == files_total then on_update() end
						end)
						async_http.dispatch()
					else
						filesystem.mkdirs(filesystem.scripts_dir() .. directory .. "\\" .. SUBFOLDER_NAME)
						for _, file in pairs(files) do
							async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/Source/" .. directory .. "/" .. file, function(contents)
								if DEV_ENVIRONMENT then
								    Ryan.Toast("Saved a file.")
								else
									local destination = assert(io.open(filesystem.scripts_dir() .. directory .. "\\" .. SUBFOLDER_NAME .. "\\" .. file, if file:find(".png") then "wb" else "w"))
									destination:write(contents)
									assert(destination:close())
								end
								files_done = files_done + 1
								if files_done == files_total then on_update() end
							end)
							async_http.dispatch()
						end
					end
				end
			elseif not force then
				updating = 0
				show_intro("Version " .. VERSION, util.current_time_millis())
				Ryan.PlaySoundFromEntity(players.user_ped(), "GTAO_FM_Events_Soundset", "Object_Dropped_Remote")
			end
		end, function()
			Ryan.ShowTextMessage(6, "Auto-Update", "Failed to get the latest version. Use the installer instead.")
		end)

		async_http.dispatch()
		while updating ~= 0 do util.yield() end
	end
end

-- Keep items in a table if the lambda returns true.
Ryan.KeepItemsInTable = function(table, keep)
	local new_i = 1
	local count = #table
	for i = 1, count do
		if keep(table, i, new_i) then
			if i ~= new_i then
				table[new_i] = table[i]
				table[i] = nil
			end
			new_i = new_i + 1
		else
			table[i] = nil
		end
	end
	return table
end

-- Remove an item from a table.
Ryan.RemoveItemInTable = function(table, element)
	local new_i = 1
	local count = #table
	for i = 1, count do
		if table[i] == element then
			if i ~= new_i then
				table[new_i] = table[i]
				table[i] = nil
			end
			new_i = new_i + 1
		else
			table[i] = nil
		end
	end
	return table
end

-- Get a random item from a table.
Ryan.GetRandomItemInTable = function(list)
	local values = {}
	for _, value in pairs(list) do table.insert(values, value) end
	return values[math.random(1, #values)]
end

-- Shuffle the items in a table.
Ryan.ShuffleItemsInTable = function(table)
	local shuffled = {}
	for i = 1, #table do shuffled[i] = table[i] end
	for i = #table, 2, -1 do
		local randomized = math.random(i)
		shuffled[i], shuffled[randomized] = shuffled[randomized], shuffled[i]
	end
	return shuffled
end

Ryan.FindItemInTable = function(table, item)
	for key, value in pairs(table) do
		if item == value then
			return key
		end
	end
	return nil
end

-- Get the name of a seat by its index.
Ryan.SeatName = function(index)
	return if index == -1 then "Driver" else ("Seat " .. (index + 2))
end

-- Get a command-friendly name.
Ryan.CommandName = function(string)
	return string:lower():gsub("[ _]", "")
end

-- Get a table-friendly name.
Ryan.ToTableName = function(string)
	return string:lower():gsub(" ", "_")
end

-- Make a table-friendly name readable.
Ryan.FromTableName = function(string)
	return string:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end):gsub("_", " ")
end

-- Format a number with commas.
Ryan.FormatNumber = function(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

-- Format a timespan, e.g. "3 minutes, 24 seconds".
Ryan.FormatTimespan = function(ms)
	local formatted = ""
	ms = ms / 1000; local s = math.floor(ms % 60)
	ms = ms / 60; local m = math.floor(ms % 60)
	ms = ms / 60; local h = math.floor(ms % 24)
	ms = ms / 24; local d = math.floor(ms)
	if d > 0 then formatted = formatted .. ", " .. d .. " day" .. (if d ~= 1 then "s" else "") end
	if h > 0 then formatted = formatted .. ", " .. h .. " hour" .. (if h ~= 1 then "s" else "") end
	if m > 0 then formatted = formatted .. ", " .. m .. " minute" .. (if m ~= 1 then "s" else "") end
	if s > 0 then formatted = formatted .. ", " .. s .. " second" .. (if s ~= 1 then "s" else "") end
	return formatted:sub(3)
end

-- What to include in a raycast.
Ryan.RaycastFlags = {
	All = -1,
	World = 1,
	Peds = 4,
	Vehicles = 10,
	Objects = 16,
	Vegetation = 256
}

-- Do a raycast from the center of the camera. TODO: raycast further from camera
Ryan.RaycastFromCamera = function(distance, flags)
	local origin = CAM.GET_FINAL_RENDERED_CAM_COORD()
	local direction = CAM.GET_FINAL_RENDERED_CAM_ROT(2):toDir()
	return Ryan.Raycast(origin, direction, distance, flags, false)
end

Ryan.Raycast = function(origin, direction, distance, flags, include_self)
	local result = {}
	local did_hit = memory.alloc(8)
	local hit_coords = v3.new()
	local hit_normal = v3.new()
	local hit_entity = memory.alloc_int()
	local destination = v3(origin)
	direction:mul(distance)
	destination:add(direction)

	SHAPETEST.GET_SHAPE_TEST_RESULT(
		SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
			origin.x, origin.y, origin.z,
			destination.x, destination.y, destination.z,
			flags or -1, if include_self then 0 else players.user_ped(), 1
		), did_hit, hit_coords, hit_normal, hit_entity
	)

	result.did_hit = memory.read_byte(did_hit) ~= 0
	result.hit_coords = hit_coords
	result.hit_normal = hit_normal
	result.hit_entity = memory.read_int(hit_entity)

	return result
end

-- Request a model and wait until it loads.
Ryan.RequestModel = function(model)
	if STREAMING.IS_MODEL_VALID(model) then
		STREAMING.REQUEST_MODEL(model)
		while not STREAMING.HAS_MODEL_LOADED(model) do
			util.yield()
		end
	else
		Ryan.Toast("Invalid model: \"" .. model .."\"!")
	end
end
	
-- Free a model that has been requested.
Ryan.FreeModel = function(model)
	STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
end

-- Request an animation set.
Ryan.RequestAnimations = function(animation_group)
	STREAMING.REQUEST_ANIM_DICT(animation_group)
	while not STREAMING.HAS_ANIM_DICT_LOADED(animation_group) do
		util.yield()
	end
end

-- Show a text message on-screen.
Ryan.ShowTextMessage = function(color, subtitle, message)
	HUD._THEFEED_SET_NEXT_POST_BACKGROUND_COLOR(color)
	GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("DIA_JESUS", 0)
	while not GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED("DIA_JESUS") do
		util.yield()
	end
	util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
	HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT("DIA_JESUS", "DIA_JESUS", true, 4, "Ryan's Menu", subtitle)
	HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(true, false)
end

-- Translate a message between languages.
Ryan.Translate = function(message, language, latin, on_result)
	Ryan.Toast("Translating...")
	async_http.init("gta.ryanmade.site", "/translate?text=" .. message .. "&language=" .. language, function(result)
		if latin then
			for from, to in pairs(Ryan.CyrillicAlphabet) do
				result = result:gsub(from, to)
			end
		end
		on_result(result)
	end, function()
		Ryan.ShowTextMessage(Ryan.BackgroundColors.Red, "Translation", "Failed to translate message.")
	end)
	async_http.dispatch()
end

-- Fire a firework launcher straight up from the specific position.
Ryan.DoFireworks = function(coords, offset)
	if coords == nil then return end
	coords = v3(coords); coords:add(offset)

	local player_ped = players.user_ped()
	local firework = util.joaat("weapon_firework")

	WEAPON.REQUEST_WEAPON_ASSET(firework)
	WEAPON.GIVE_WEAPON_TO_PED(player_ped, firework, 20, false, true)
	WEAPON.SET_CURRENT_PED_WEAPON(player_ped, util.joaat("weapon_unarmed"), false)
	MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z + 100, 0, false, firework, player_ped, true, false, 500.0)
	WEAPON.REFILL_AMMO_INSTANTLY(player_ped)
end

-- Teleport with or without our vehicle.
Ryan.Teleport = function(coords, with_vehicle)
	Ryan.Toast("Teleporting...")
	local player_ped = players.user_ped()
	if with_vehicle and players.get_vehicle_model(players.user()) ~= 0 then
		local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
		ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z)
	else
		ENTITY.SET_ENTITY_COORDS(player_ped, coords.x, coords.y, coords.z)
	end
end

-- Get the closest node to the specified coords.
Ryan.GetClosestNode = function(coords, with_third_eye)
	if with_third_eye then
		Ryan.OpenThirdEye(coords)
		util.yield(1000)
	end

	local node = v3.new()
	PATHFIND.GET_CLOSEST_VEHICLE_NODE(coords.x, coords.y, coords.z, node, 1, 3.0, 0)

	if with_third_eye then
		Ryan.CloseThirdEye()
	end

	return node
end

-- Temporarily teleport to a player while ghosted.
local _starting_coords = nil
local _starting_vehicle, _starting_seat = nil, nil
local _starting_in_ghost_mode = nil
local _starting_can_ragdoll = nil

Ryan.OpenThirdEye = function(coords, with_vehicle)
	local ghost_menu = menu.ref_by_path("Stand>Lua Scripts>" .. SUBFOLDER_NAME .. ">Self>Character...>Ghost Mode")
	if not _starting_in_ghost_mode then menu.trigger_command(menu.ref_by_rel_path(ghost_menu, "Character Only")) end

	local user = Player:Self()
	_starting_coords = v3(user.coords)
	_starting_seat = user:get_vehicle_seat()
	_starting_vehicle = if _starting_seat ~= nil then entities.get_user_vehicle_as_handle() else nil
	_starting_in_ghost_mode = Ryan.GhostMode > 1
	_starting_can_ragdoll = PED.CAN_PED_RAGDOLL(user.ped_id)
	Ryan.Teleport(coords, with_vehicle)
end

Ryan.CloseThirdEye = function()
	local ghost_menu = menu.ref_by_path("Stand>Lua Scripts>" .. SUBFOLDER_NAME .. ">Self>Character...>Ghost Mode")
	if not _starting_in_ghost_mode then menu.trigger_command(menu.ref_by_rel_path(ghost_menu, "Off")) end

	if _starting_coords ~= nil then Ryan.Teleport(_starting_coords, false) end -- why?
	if _starting_vehicle ~= nil then PED.SET_PED_INTO_VEHICLE(players.user_ped(), _starting_vehicle, _starting_seat) end
	PED.SET_PED_CAN_RAGDOLL(players.user_ped(), _starting_can_ragdoll)

	return _starting_coords
end

-- Send a chat message, fall back to SMS so Stand doesn't ratelimit us.
_repeat_messages = {}
Ryan.SendChatMessage = function(message)
	local message_hash = util.joaat(message)
	if _repeat_messages[message_hash] == nil or util.current_time_millis() - _repeat_messages[message_hash] >= 3600000 then
		chat.send_message(message, false, true, true)
		_repeat_messages[util.joaat(message)] = util.current_time_millis()
	else
		for _, player in pairs(Player:List(true, true, true)) do
			player:send_sms(message)
		end
	end
end

-- Draw an AR Beacon with the specified HUD color.
Ryan.DrawBeacon = function(coords)
	local ref = menu.ref_by_path("Stand>Settings>Appearance>Colours>AR Colour")
	local r, g, b, a = menu.ref_by_rel_path(ref, "Red"), menu.ref_by_rel_path(ref, "Green"), menu.ref_by_rel_path(ref, "Blue"), menu.ref_by_rel_path(ref, "Opacity")
	local original_color = {r = menu.get_value(r), g = menu.get_value(g), b = menu.get_value(b), a = menu.get_value(a)}

	menu.trigger_command(r, math.floor(Ryan.HUDColor.r * 255))
	menu.trigger_command(g, math.floor(Ryan.HUDColor.g * 255))
	menu.trigger_command(b, math.floor(Ryan.HUDColor.b * 255))
	menu.trigger_command(a, 20)

	util.draw_ar_beacon(coords)

	menu.trigger_command(r, original_color.r)
	menu.trigger_command(g, original_color.g)
	menu.trigger_command(b, original_color.b)
	menu.trigger_command(a, original_color.a)
end

-- Stat scopes.
Ryan.StatType = {
	Global = 1,
	Character = 2
}

-- Get the hash of a stat based on its scope.
Ryan.GetStatHash = function(stat_type, stat_name)
	local prefix = nil
	if stat_type == Ryan.StatType.Global then prefix = "MPPLY"
	else prefix = "MP" .. Ryan.GetStatInt(Ryan.GetStatHash(Ryan.StatType.Global, "LAST_MP_CHAR")) end
	return util.joaat(prefix .. "_" .. stat_name)
end

-- Get an integer stat.
Ryan.GetStatInt = function(key)
	local value = memory.alloc_int()
	STATS.STAT_GET_INT(key, value, -1)
	return memory.read_int(value)
end

-- Play a sound locally in 2D.
Ryan.PlaySound = function(sound_group, sound_name)
    AUDIO.PLAY_SOUND_FRONTEND(-1, sound_name, sound_group)
end

-- Play a sound coming from an entity in 3D.
Ryan.PlaySoundFromEntity = function(entity, sound_group, sound_name)
    AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound_name, entity, sound_group, true, true)
end

-- Play a sound coming from a position in 3D.
Ryan.PlaySoundAtCoords = function(coords, sound_group, sound_name, range)
    AUDIO.PLAY_SOUND_FROM_COORD(-1, sound_name, coords.x, coords.y, coords.z, sound_group, true, range, true)
end

-- Play a sound on all players at once.
Ryan.PlaySoundOnAllPlayers = function(sound_group, sound_name)
    for _, player_id in pairs(players.list()) do
        Ryan.PlaySoundFromEntity(Player:Get(player_id).ped_id, sound_group, sound_name)
    end
end

-- Play the button-press sound effect.
Ryan.PlaySelectSound = function()
    Ryan.PlaySound("HUD_FRONTEND_MP_SOUNDSET", "SELECT")
end

-- Play the button-press sound effect when a value changes.
Ryan.ToggleSelectSound = function(value, state, key)
    if value[key] == true and state[key] ~= true then
        Ryan.PlaySelectSound()
        state[key] = true
    elseif value[key] ~= true and state[key] == true then
        Ryan.PlaySelectSound()
        state[key] = nil
    end
end