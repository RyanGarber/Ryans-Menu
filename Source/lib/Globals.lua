Ryan.Globals = {}
_waiting_for_session = false
_waiting_for_coords = nil

Ryan.Globals.HUDColor = {r = 0.29, g = 0.69, b = 1.0}
Ryan.Globals.HUDUseBeacon = false

Ryan.Globals.PlayerIsPointing = false
Ryan.Globals.PlayerIsSwitchingSessions = false

-- Initialize globals.
Ryan.Globals.Initialize = function()
    Ryan.Globals.CrosshairTexture = directx.create_texture(filesystem.resources_dir() .. SUBFOLDER_NAME .. "\\Crosshair.png")
    Ryan.Basics.RequestModel(util.joaat("p_poly_bag_01_s"))
end

-- Update globals on each tick.
Ryan.Globals.OnTick = function()
    if not NETWORK.NETWORK_IS_SESSION_ACTIVE() then
        _waiting_for_session = true
        _waiting_for_coords = nil
    end
    if _waiting_for_session then
        if NETWORK.NETWORK_IS_SESSION_ACTIVE() then
            _waiting_for_session = false
            _waiting_for_coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        end
    end
    if _waiting_for_coords ~= nil then
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        if Ryan.Vector.Distance(coords, _waiting_for_coords) > 0.1 then
            _waiting_for_coords = nil
        end
    end

    Ryan.Globals.PlayerIsPointing = memory.read_int(memory.script_global(4521801 + 930)) == 3
    Ryan.Basics.PlayerIsSwitchingSessions = not (_waiting_for_session or _waiting_for_coords)
end

-- Background colors for certain UI elements.
Ryan.Globals.BackgroundColors = {
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
Ryan.Globals.Controls = {
    CharacterWheel         = 19,  -- Alt
    MultiplayerInfo        = 20,  -- Z
    Sprint                 = 21,  -- Shift
    Enter                  = 23,  -- F
    LookBehind             = 26,  -- C
    Cover                  = 44,  -- Q
    Reload                 = 45,  -- R
    HudSpecial             = 48,  -- Z
    VehicleDuck            = 73,  -- X
    VehicleExit            = 75,  -- F
    VehicleLookBehind      = 79,  -- C
    VehicleCinematicCamera = 80,  -- R
    VehicleRadioWheel      = 85,  -- Q
    VehicleHorn            = 86,  -- E
    MeleeAttackLight       = 140, -- R
    SelectWeaponUnarmed    = 157, -- 1
    SelectWeaponMelee      = 158, -- 2
    SelectWeaponShotgun    = 160, -- 3
    SelectWeaponHeavy      = 164, -- 4
    SelectWeaponSpecial    = 165, -- 5
}

-- Translation languages.
Ryan.Globals.Languages = {
    {"Spanish", "ES", false},
    {"French", "FR", false},
    {"Italian", "IT", false},
    {"German", "DE", false},
    {"Chinese", "ZH", false},
    {"Russian", "RU", false},
}

-- Cyrillic/Latin transliteration table.
Ryan.Globals.CyrillicAlphabet = {
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
Ryan.Globals.ActionFigures = {
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
Ryan.Globals.SignalJammers = {
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
Ryan.Globals.PlayingCards = {
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
Ryan.Globals.MovieProps = {
    {94, -1293, 29}, {-1010, -501, 38}, {2517, 3789, 54}, {-2348, 3270, 33},
    {-41, 2873, 60}, {-1169, 4926, 224}, {1165.2252, 248.03876, -51}
}

-- The Slasher's clue coordinates.
Ryan.Globals.SlasherClues = {
    {-135.03899, 1912.0951, 197.3230}, {1113.9885, 3142.3547, 38.558643},
    {1904.079, 4911.179, 48.846428}, {-680.2069, 5798.918, 17.33097}
}

-- The Slasher's van coordinates.
Ryan.Globals.SlasherVans = {
    {2436.439, 5842.429, 58.72461}, {2896.4573, 3674.395, 45.182766},
    {2569.6438, 1259.2722, 44.39878}, {-1551.7269, 4404.269, 6.6305246},
    {-1710.8304, 2621.2546, 3}
}

-- The Slasher's final event coordinates.
Ryan.Globals.SlasherFinale = {
    1320.2701, 3140.9683, 40.42251
}

-- Treasure Hunt coordinates.
Ryan.Globals.Treasures = {
    {-1913.0719, 1388.7817, 219.14182}, {1924.326, 3986.48, 32.19},
    {1994.7795, 5078.7495, 42.685287}
}

-- USB Music Stick coordinates.
Ryan.Globals.USBSticks = {
    {-2172.587, 1159.6364, -24.372166}, {2725.424, -382.7012, -48.97467},
    {-1618.6365, -3010.6003, -75.205}, {955.64325, 49.459408, 112.55278}
}

-- Vehicle bones useful for attaching to.
Ryan.Globals.VehicleAttachBones = {
    {"Center", nil},
    {"Hood", "bonnet"},
    {"Windshield", "windscreen"},
    {"License Plate", "numberplate"},
    {"Exhaust", "exhaust"},
    {"Trunk", "boot"}
}

-- Forcefield types.
Ryan.Globals.ForcefieldForces = {"None", "Push", "Pull", "Spin", "Up", "Down", "Smash", "Chaos", "Explode"}

-- God Finger force types.
Ryan.Globals.GodFingerForces = {"Default", "Push", "Pull", "Spin", "Up", "Down", "Smash", "Chaos", "Explode"}

-- Anti-hermit punishment modes.
Ryan.Globals.AntihermitModes = {"Off", "Teleport Outside", "Kick", "Crash"}

-- NPC scenario types.
Ryan.Globals.NPCScenarios = {"Off", "Musician", "Human Statue", "Paparazzi", "Janitor", "Nude", "Delete"}

-- Coordinates for the best earrape known to man.
Ryan.Globals.BedSoundCoords = {
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
Ryan.Globals.PedGroups = {
    LawEnforcement = {6, 27, 29}
}
Ryan.Globals.PedModels = {
    CayoPericoHeist = {1821116645, 193469166, 2127932792},
    CasinoHeist = {1885233650, -1094177627, 337826907},
    DoomsdayHeist = {-1275859404, 1650288984, 1297520375, 2618542997, 2431602996}
}

-- Hashes of vehicles that can haul trailers.
Ryan.Globals.Haulers = {
    1518533038, 387748548, 371926404, -1649536104, 177270108
}

-- Ped task IDs.
Ryan.Globals.Tasks = {
    ["ExitVehicle"] = 2,
    ["EnterVehicle"] = 160
}