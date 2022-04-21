-- Fundamentals --
function basics_run(commands)
	for i = 1, #commands do
		menu.trigger_commands(commands[i])
	end
end

function basics_keep(table, keep)
    local new_i = 1
	local count = #table
    for i = 1, count do
        if keep(table, i, new_i) then
            if i ~= new_i then
                table[new_i] = table[i];
                table[i] = nil;
            end
            new_i = new_i + 1;
        else
            table[i] = nil;
        end
    end
    return table;
end

function basics_remove(table, element)
    local new_i = 1
	local count = #table
    for i = 1, count do
        if table[i] == element then
            if i ~= new_i then
                table[new_i] = table[i];
                table[i] = nil;
            end
            new_i = new_i + 1;
        else
            table[i] = nil;
        end
    end
    return table;
end

function basics_get_random(table) -- Credit: WiriScript
	if rawget(table, 1) ~= nil then return table[math.random(1, #table)] end
	local list = {}
	for _, value in pairs(table) do table.insert(list, value) end
	return list[math.random(1, #list)]
end

function basics_shuffle(list)
    local shuffled = {}
    for i = 1, #list do shuffled[i] = list[i] end
    for i = #list, 2, -1 do
        local randomized = math.random(i)
        shuffled[i], shuffled[randomized] = shuffled[randomized], shuffled[i]
    end
    return shuffled
end

function basics_command_name(display_name)
	return display_name:lower():gsub(" ", "")
end

function basics_format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function basics_format_time(ms)
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
end

function basics_do_raycast(distance, flags) -- Credit: WiriScript
    flags = flags or -1
    local result = {}
	local did_hit = memory.alloc(8)
	local hit_coords = v3.new()
	local hit_normal = v3.new()
	local hit_entity = memory.alloc_int()
	local origin = CAM.GET_FINAL_RENDERED_CAM_COORD()
	local destination = vector_offset_from_camera(distance)

	SHAPETEST.GET_SHAPE_TEST_RESULT(
		SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
			origin.x, origin.y, origin.z,
			destination.x, destination.y, destination.z,
			flags, PLAYER.PLAYER_PED_ID(), 1
		), did_hit, hit_coords, hit_normal, hit_entity
	)
	result.did_hit = memory.read_byte(did_hit) ~= 0
	result.hit_coords = vector_v3_to_object(v3.get(hit_coords))
	result.hit_normal = vector_v3_to_object(v3.get(hit_normal))
	result.hit_entity = memory.read_int(hit_entity)

	memory.free(did_hit)
	v3.free(hit_coords)
	v3.free(hit_normal)
	memory.free(hit_entity)
	return result
end


-- Streaming --
function basics_request_model(model)
    if STREAMING.IS_MODEL_VALID(model) then
        STREAMING.REQUEST_MODEL(model)
        while not STREAMING.HAS_MODEL_LOADED(model) do
            util.yield()
        end
    else
        util.toast("Invalid model '" .. model .."', please report this issue to Ryan.")
    end
end

function basics_request_animations(animation_group)
    STREAMING.REQUEST_ANIM_DICT(animation_group)
    while not STREAMING.HAS_ANIM_DICT_LOADED(animation_group) do
        util.yield()
    end
end


-- UI --
function basics_show_text_message(color, subtitle, message)
    HUD._THEFEED_SET_NEXT_POST_BACKGROUND_COLOR(color)
	GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("DIA_JESUS", 0)
	while not GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED("DIA_JESUS") do
		util.yield()
	end
	util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
	HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT("DIA_JESUS", "DIA_JESUS", true, 4, "Ryan's Menu", subtitle)
	HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(true, false)
end

function basics_esp_box(entity)
    local color = {r = math.floor(esp_color.r * 255), g = math.floor(esp_color.g * 255), b = math.floor(esp_color.b * 255)}
    local minimum = v3.new()
	local maximum = v3.new()
	if ENTITY.DOES_ENTITY_EXIST(entity) then
		MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(entity), minimum, maximum)
		local width  = 2 * v3.getX(maximum)
		local length = 2 * v3.getY(maximum)
		local depth  = 2 * v3.getZ(maximum)

		local offset1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2,  depth / 2)
		local offset4 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2,  depth / 2)
		local offset5 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2,  length / 2, -depth / 2)
		local offset7 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2,  length / 2, -depth / 2)
		local offset2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2,  depth / 2) 
		local offset3 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2,  depth / 2)
		local offset6 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -width / 2, -length / 2, -depth / 2)
		local offset8 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity,  width / 2, -length / 2, -depth / 2)

		GRAPHICS.DRAW_LINE(offset1.x, offset1.y, offset1.z, offset4.x, offset4.y, offset4.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset1.x, offset1.y, offset1.z, offset2.x, offset2.y, offset2.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset1.x, offset1.y, offset1.z, offset5.x, offset5.y, offset5.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset2.x, offset2.y, offset2.z, offset3.x, offset3.y, offset3.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset3.x, offset3.y, offset3.z, offset8.x, offset8.y, offset8.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset4.x, offset4.y, offset4.z, offset7.x, offset7.y, offset7.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset4.x, offset4.y, offset4.z, offset3.x, offset3.y, offset3.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset5.x, offset5.y, offset5.z, offset7.x, offset7.y, offset7.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset6.x, offset6.y, offset6.z, offset2.x, offset2.y, offset2.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset6.x, offset6.y, offset6.z, offset8.x, offset8.y, offset8.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset5.x, offset5.y, offset5.z, offset6.x, offset6.y, offset6.z, color.r, color.g, color.b, 255)
		GRAPHICS.DRAW_LINE(offset7.x, offset7.y, offset7.z, offset8.x, offset8.y, offset8.z, color.r, color.g, color.b, 255)
	end
	v3.free(minimum)
	v3.free(maximum)
end