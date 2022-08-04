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

	StringToCommandName = function(string)
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
			menu.toggle(choices_root, choice, {command_name .. Ryan.Basics.StringToCommandName(choice)}, "", function(value)
				if value then
					if choice ~= state then
						menu.trigger_commands(command_name .. Ryan.Basics.StringToCommandName(state) .. " off")
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
				if not has_choice then menu.trigger_commands(command_name .. Ryan.Basics.StringToCommandName(choices[1]) .. " on") end
				state_change = 2147483647
			end
		end)

		on_update(state)
		return choices_root
	end
}