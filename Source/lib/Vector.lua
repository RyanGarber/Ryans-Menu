function vector_add(vector_1, vector_2)
    return {x = vector_1.x + vector_2.x, y = vector_1.y + vector_2.y, z = vector_1.z + vector_2.z}
end

function vector_subtract(vector_1, vector_2)
    return {x = vector_1.x - vector_2.x, y = vector_1.y - vector_2.y, z = vector_1.z - vector_2.z}
end

function vector_multiply(vector, amount)
    return {x = vector.x * amount, y = vector.y * amount, z = vector.z * amount}
end

function vector_distance(vector_1, vector_2)
    return vector_magnitude(vector_subtract(vector_1, vector_2))
end

function vector_magnitude(vector)
    return math.sqrt(vector.x ^ 2 + vector.y ^ 2 + vector.z ^ 2)
end

function vector_normalize(vector)
    return vector_multiply(vector, 1 / vector_magnitude(vector))
end

function v3_to_object(X, Y, Z)
    return {x = X, y = Y, z = Z}
end

function vector_rotation_to_direction(rotation) -- Credit: WiriScript
	local adjusted_rotation = { 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = {
		x = - math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
		y =   math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
		z =   math.sin(adjusted_rotation.x)
	}
	return direction
end

function vector_offset_from_camera(distance) -- Credit: WiriScript
	local position = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local rotation = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
	local direction = vector_rotation_to_direction(rotation)
	local offset = {
		x = position.x + direction.x * distance,
		y = position.y + direction.y * distance,
		z = position.z + direction.z * distance 
	}
	return offset
end