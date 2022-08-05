-- Fundamentals --
Ryan.Basics = {
	RunCommands = function(commands)
		for i = 1, #commands do
			menu.trigger_commands(commands[i])
		end
	end,

	KeepItemsInTable = function(table, keep)
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
	end,

	RemoveItemInTable = function(table, element)
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
	end,

	GetRandomItemInTable = function(table)
		if rawget(table, 1) ~= nil then return table[math.random(1, #table)] end
		local list = {}
		for _, value in pairs(table) do table.insert(list, value) end
		return list[math.random(1, #list)]
	end,

	ShuffleItemsInTable = function(table)
		local shuffled = {}
		for i = 1, #table do shuffled[i] = table[i] end
		for i = #table, 2, -1 do
			local randomized = math.random(i)
			shuffled[i], shuffled[randomized] = shuffled[randomized], shuffled[i]
		end
		return shuffled
	end,

	CommandName = function(string)
		return string:lower():gsub(" ", "")
	end,

	FormatNumber = function(number)
		local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
		int = int:reverse():gsub("(%d%d%d)", "%1,")
		return minus .. int:reverse():gsub("^,", "") .. fraction
	end,

	FormatTimespan = function(ms)
		local formatted = ""
		ms = ms / 1000; local s = math.floor(ms % 60)
		ms = ms / 60; local m = math.floor(ms % 60)
		ms = ms / 60; local h = math.floor(ms % 24)
		ms = ms / 24; local d = math.floor(ms)
		if d > 0 then formatted = formatted .. ", " .. d .. " day" .. (d ~= 1 and "s" or "") end
		if h > 0 then formatted = formatted .. ", " .. h .. " hour" .. (h ~= 1 and "s" or "") end
		if m > 0 then formatted = formatted .. ", " .. m .. " minute" .. (m ~= 1 and "s" or "") end
		if s > 0 then formatted = formatted .. ", " .. s .. " second" .. (s ~= 1 and "s" or "") end
	    return formatted:sub(3)
	end,

	RaycastFlags = {
		World = 1,
		Vehicles = 2,
		Peds = 8,
		Objects = 16,
		Water = 32,
		Foliage = 256
	},

	Raycast = function(distance, flags)
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
		result.hit_coords = Ryan.Vector.FromV3(v3.get(hit_coords))
		result.hit_normal = Ryan.Vector.FromV3(v3.get(hit_normal))
		result.hit_entity = memory.read_int(hit_entity)

		return result
	end,

	RequestModel = function(model)
		if STREAMING.IS_MODEL_VALID(model) then
			STREAMING.REQUEST_MODEL(model)
			while not STREAMING.HAS_MODEL_LOADED(model) do
				util.yield()
			end
		else
			util.toast("Invalid model '" .. model .."', please report this issue to Ryan.")
		end
	end,
	
	FreeModel = function(model)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
	end,

	RequestAnimations = function(animation_group)
		STREAMING.REQUEST_ANIM_DICT(animation_group)
		while not STREAMING.HAS_ANIM_DICT_LOADED(animation_group) do
			util.yield()
		end
	end,

	ShowTextMessage = function(color, subtitle, message)
		HUD._THEFEED_SET_NEXT_POST_BACKGROUND_COLOR(color)
		GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("DIA_JESUS", 0)
		while not GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED("DIA_JESUS") do
			util.yield()
		end
		util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
		HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT("DIA_JESUS", "DIA_JESUS", true, 4, "Ryan's Menu", subtitle)
		HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(true, false)
	end,

	TranslateFrom = function(message)
		async_http.init("gta.ryanmade.site", "/translate?text=" .. message .. "&language=EN", function(result)
			Ryan.Basics.ShowTextMessage(Ryan.Globals.Color.Purple, "Translation", result)
		end, function()
			util.toast("Failed to translate message.")
		end)
		async_http.dispatch()
	end,

	TranslateTo = function(message, language, latin)
		async_http.init("gta.ryanmade.site", "/translate?text=" .. message .. "&language=" .. language, function(result)
			if latin then
				for from, to in pairs(Ryan.Globals.CyrillicAlphabet) do
					result = result:gsub(from, to)
				end
			end
			chat.send_message(result, false, true, true)
			util.toast("Sent!")
		end, function()
			util.toast("Failed to translate message.")
		end)
		async_http.dispatch()
	end,

	CreateSavableChoiceWithDefault = function(root, menu_name, command_name, description, choices, on_update)
		local state = choices[1]
		local state_change = 2147483647
		local state_values = {[state] = true}

		local choices_root = menu.list(root, menu_name:gsub("%%", state), {command_name}, description)
		for _, choice in pairs(choices) do
			menu.toggle(choices_root, choice, {command_name .. Ryan.Basics.CommandName(choice)}, "", function(value)
				if value then
					if choice ~= state then
						menu.trigger_commands(command_name .. Ryan.Basics.CommandName(state) .. " off")
						util.yield(500)
						state = choice
						on_update(state)
						menu.set_menu_name(choices_root, menu_name:gsub("%%", state))
					end
				end

				state_change = util.current_time_millis()
				state_values[choice] = value
			end, choice == choices[1])
		end

		util.create_tick_handler(function()
			if util.current_time_millis() - state_change > 500 then
				local has_choice = false
				for _, choice in pairs(choices) do
					if state_values[choice] then has_choice = true end
				end
				if not has_choice then menu.trigger_commands(command_name .. Ryan.Basics.CommandName(choices[1]) .. " on") end
				state_change = 2147483647
			end
		end)

		on_update(state)
		return choices_root
	end,

	GetGodFingerEffectActivation = function(key)
		if key == "Look"       then return 1
		elseif key == "Hold Q" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.Cover) and 2 or 0
		elseif key == "Hold E" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.VehicleHorn) and 2 or 0
		elseif key == "Hold R" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.Reload) and 2 or 0
		elseif key == "Hold F" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.Enter) and 2 or 0
		elseif key == "Hold C" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.LookBehind) and 2 or 0
		elseif key == "Hold X" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.VehicleDuck) and 2 or 0
		elseif key == "Hold Z" then return PAD.IS_DISABLED_CONTROL_PRESSED(21, Ryan.Globals.Controls.MultiplayerInfo) and 2 or 0
		else                   return 0 end
	end,

	IsGodFingerEffectActivated = function(key)
		activation = Ryan.Basics.GetGodFingerEffectActivation(key)
		--if activation == 2 and player_is_pointing then god_finger_last_activation = util.current_time_millis() end
		return activation > 0
	end,

	GetGodFingerEffectHelp = function(effects)
		function icon(mode)
			if mode == "Hold Q"     then return "~INPUT_COVER~"
			elseif mode == "Hold E" then return "~INPUT_VEH_HORN~"
			elseif mode == "Hold R" then return "~INPUT_RELOAD~"
			elseif mode == "Hold F" then return "~INPUT_ENTER~"
			elseif mode == "Hold C" then return "~INPUT_LOOK_BEHIND~"
			elseif mode == "Hold X" then return "~INPUT_VEH_DUCK~"
			elseif mode == "Hold Z" then return "~INPUT_VEH_RADIO_WHEEL~" end
    	end

		function split(help, new_help)
			local help_line = help:sub(1 - (help:reverse():find("\n") or 0))
			local help_line_length = help_line:gsub("~[A-Z_]+~", ""):gsub("   ", ""):len()
			local new_help_length = new_help:gsub("~[A-Z_]+~", ""):gsub("   ", ""):len()
			if help_line_length + new_help_length >= 30 then return "\n" .. new_help
			else return (help_line_length > 0 and "   " or "") .. new_help end
		end

		help = ""

		for effect, value in pairs(effects) do
			if type(value) == "table" then
				for choice, mode in pairs(value) do
					if mode:find("Hold") then
						help = help .. split(help, icon(mode) .. " " .. Ryan.Basics.FromTableName(effect) .. ": " .. Ryan.Basics.FromTableName(choice))
					end
				end
			else
				if value:find("Hold") then
					help = help .. split(help, icon(value) .. " " .. Ryan.Basics.FromTableName(effect))
				end
			end
		end

    	return help
	end,

	DisableGodFingerKeys = function()
		util.toast("Disabling controls")
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.Cover, god_finger_active)                  -- Q
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleRadioWheel, god_finger_active)      -- Q
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleHorn, god_finger_active)            -- E
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.Reload, god_finger_active)                 -- R
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.MeleeAttackLight, god_finger_active)       -- R
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleCinematicCamera, god_finger_active) -- R
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.Enter, god_finger_active)                  -- F
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleExit, god_finger_active)            -- F
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.LookBehind, god_finger_active)             -- C
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleLookBehind, god_finger_active)      -- C
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.VehicleDuck, god_finger_active)            -- X
		PAD.DISABLE_CONTROL_ACTION(0, Ryan.Globals.Controls.MultiplayerInfo, god_finger_active)        -- Z
	end,

	ToTableName = function(string)
		return string:lower():gsub(" ", "_")
	end,

	FromTableName = function(string)
		return string:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end):gsub("_", " ")
	end
}