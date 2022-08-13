Ryan.Basics = {}

-- Download the latest version if a new one is available, or if force == true.
Ryan.Basics.DoUpdate = function(force)
	if not DEV_ENVIRONMENT or force then
		local updating = 1

		async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/MANIFEST", function(manifest)
			latest_version = manifest:sub(1, manifest:find("\n") - 1)
			manifest = Ryan.JSON.Decode(manifest:sub(manifest:find("\n"), manifest:len()))
			
			if latest_version ~= VERSION or force then
				updating = 2

				util.show_corner_help("<b>Updating Ryan's Menu</b><br>Now downloading v" .. latest_version .. ". Please wait...")
				
				-- -- Download Update
				local files_total, files_done = 0, 0
				for directory, files in pairs(manifest) do
					files_total = files_total + (if directory == "main" then 1 else #files)
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
						filesystem.mkdirs(filesystem.scripts_dir() .. directory .. "\\" .. SUBFOLDER_NAME)
						for _, file in pairs(files) do
							async_http.init("raw.githubusercontent.com", "/RyanGarber/Ryans-Menu/main/Source/" .. directory .. "/" .. file, function(contents)
								local destination = assert(io.open(filesystem.scripts_dir() .. directory .. "\\" .. SUBFOLDER_NAME .. "\\" .. file, if file:find(".png") then "wb" else "w"))
								destination:write(contents)
								assert(destination:close())
								files_done = files_done + 1
								if files_done == files_total then on_update() end
							end)
							async_http.dispatch()
						end
					end
				end
			elseif not force then
				updating = 0

				Ryan.Basics.ShowTextMessage(49, "Auto-Update", "You're up to date. Enjoy!")
				Ryan.Audio.PlayFromEntity(players.user_ped(), "GTAO_FM_Events_Soundset", "Object_Dropped_Remote")
			end
		end, function()
			Ryan.Basics.ShowTextMessage(6, "Auto-Update", "Failed to get the latest version. Use the installer instead.")
		end)

		async_http.dispatch()
		
		while updating ~= 0 do
			if updating == 2 then util.toast("Downloading files for Ryan's Menu...") end

			util.yield(333)
		end		
	end
end

-- Run multiple commands at once.
Ryan.Basics.RunCommands = function(commands)
	for i = 1, #commands do
		menu.trigger_commands(commands[i])
	end
end

-- Keep items in a table if the lambda returns true.
Ryan.Basics.KeepItemsInTable = function(table, keep)
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
Ryan.Basics.RemoveItemInTable = function(table, element)
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
Ryan.Basics.GetRandomItemInTable = function(table)
	local values = {}
	for _, value in pairs(table) do table.insert(values, value) end
	return values[math.random(1, #values)]
end

-- Shuffle the items in a table.
Ryan.Basics.ShuffleItemsInTable = function(table)
	local shuffled = {}
	for i = 1, #table do shuffled[i] = table[i] end
	for i = #table, 2, -1 do
		local randomized = math.random(i)
		shuffled[i], shuffled[randomized] = shuffled[randomized], shuffled[i]
	end
	return shuffled
end

-- Get the name of a seat by its index.
Ryan.Basics.SeatName = function(index)
	return if index == -1 then "Driver" else ("Seat " .. (index + 2))
end

-- Get a command-friendly name.
Ryan.Basics.CommandName = function(string)
	return string:lower():gsub("[ _]", "")
end

-- Get a table-friendly name.
Ryan.Basics.ToTableName = function(string)
	return string:lower():gsub(" ", "_")
end

-- Make a table-friendly name readable.
Ryan.Basics.FromTableName = function(string)
	return string:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end):gsub("_", " ")
end

-- Format a number with commas.
Ryan.Basics.FormatNumber = function(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

-- Format a timespan, e.g. "3 minutes, 24 seconds".
Ryan.Basics.FormatTimespan = function(ms)
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
Ryan.Basics.RaycastFlags = {
	World = 1,
	Vehicles = 2,
	Peds = 8,
	Objects = 16,
	Water = 32,
	Foliage = 256
}

-- Do a raycast from the center of the camera.
Ryan.Basics.Raycast = function(distance, flags)
	flags = flags or -1
	local result = {}
	local did_hit = memory.alloc(8)
	local hit_coords = v3.new()
	local hit_normal = v3.new()
	local hit_entity = memory.alloc_int()
	local origin = CAM.GET_FINAL_RENDERED_CAM_COORD()
	local destination = Ryan.Vector.GetOffsetFromCamera(distance)

	SHAPETEST.GET_SHAPE_TEST_RESULT(
		SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
			origin.x, origin.y, origin.z,
			destination.x, destination.y, destination.z,
			flags or -1, PLAYER.PLAYER_PED_ID(), 1
		), did_hit, hit_coords, hit_normal, hit_entity
	)

	result.did_hit = memory.read_byte(did_hit) ~= 0
	result.hit_coords = hit_coords
	result.hit_normal = hit_normal
	result.hit_entity = memory.read_int(hit_entity)

	return result
end

-- Request a model and wait until it loads.
Ryan.Basics.RequestModel = function(model)
	if STREAMING.IS_MODEL_VALID(model) then
		STREAMING.REQUEST_MODEL(model)
		while not STREAMING.HAS_MODEL_LOADED(model) do
			util.yield()
		end
	else
		util.toast("Invalid model: \"" .. model .."\"!")
	end
end
	
-- Free a model that has been requested.
Ryan.Basics.FreeModel = function(model)
	STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
end

-- Request an animation set.
Ryan.Basics.RequestAnimations = function(animation_group)
	STREAMING.REQUEST_ANIM_DICT(animation_group)
	while not STREAMING.HAS_ANIM_DICT_LOADED(animation_group) do
		util.yield()
	end
end

-- Show a text message on-screen.
Ryan.Basics.ShowTextMessage = function(color, subtitle, message)
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
Ryan.Basics.Translate = function(message, language, latin, on_result)
	util.toast("Translating...")
	async_http.init("gta.ryanmade.site", "/translate?text=" .. message .. "&language=" .. language, function(result)
		if latin then
			for from, to in pairs(Ryan.Globals.CyrillicAlphabet) do
				result = result:gsub(from, to)
			end
		end
		on_result(result)
	end, function()
		Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Red, "Translation", "Failed to translate message.")
	end)
	async_http.dispatch()
end

-- Fire a firework launcher straight up from the specific position.
Ryan.Basics.DoFireworks = function(coords, offset)
	if coords == nil then return end
	coords = Ryan.Vector.Add(coords, offset)

	local firework = util.joaat("weapon_firework")
	local player_ped = players.user_ped()
	WEAPON.REQUEST_WEAPON_ASSET(firework)
	WEAPON.GIVE_WEAPON_TO_PED(player_ped, firework, 20, false, true)
	MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z + 100, 0, true, firework, player_ped, true, false, 500.0)
end

-- Teleport with or without our vehicle.
Ryan.Basics.Teleport = function(coords, with_vehicle)
	util.toast("Teleporting...")
	local player_ped = players.user_ped()
	if with_vehicle and PED.IS_PED_IN_ANY_VEHICLE(player_ped, true) then
		local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
		ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z)
	else
		ENTITY.SET_ENTITY_COORDS(player_ped, coords.x, coords.y, coords.z)
	end
end

-- Send a chat message, fall back to SMS if Stand ratelimits us.
Ryan.Basics.SendChatMessage = function(message)
	chat.send_message(message, false, true, true)
	-- TODO: for _, player in pairs(Ryan.Player.List(true, true, true)) do player.send_sms(message) end
end

-- Draw an AR Beacon with the specified HUD color.
Ryan.Basics.DrawBeacon = function(coords)
	local ref = menu.ref_by_path("Stand>Settings>Appearance>Colours>AR Colour")
	local r, g, b, a = menu.ref_by_rel_path(ref, "Red"), menu.ref_by_rel_path(ref, "Green"), menu.ref_by_rel_path(ref, "Blue"), menu.ref_by_rel_path(ref, "Opacity")
	local original_color = {r = menu.get_value(r), g = menu.get_value(g), b = menu.get_value(b), a = menu.get_value(a)}

	menu.trigger_command(r, math.floor(Ryan.Globals.HUDColor.r * 255))
	menu.trigger_command(g, math.floor(Ryan.Globals.HUDColor.g * 255))
	menu.trigger_command(b, math.floor(Ryan.Globals.HUDColor.b * 255))
	menu.trigger_command(a, 10)

	util.draw_ar_beacon(coords)

	menu.trigger_command(r, original_color.r)
	menu.trigger_command(g, original_color.g)
	menu.trigger_command(b, original_color.b)
	menu.trigger_command(a, original_color.a)
end