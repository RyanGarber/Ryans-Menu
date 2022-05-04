Ryan.Vector = {
	Add = function(vector_1, vector_2)
		return {x = vector_1.x + vector_2.x, y = vector_1.y + vector_2.y, z = vector_1.z + vector_2.z}
	end,

	Subtract = function(vector_1, vector_2)
		return {x = vector_1.x - vector_2.x, y = vector_1.y - vector_2.y, z = vector_1.z - vector_2.z}
	end,

	Multiply = function(vector, amount)
		return {x = vector.x * amount, y = vector.y * amount, z = vector.z * amount}
	end,

	Distance = function(vector_1, vector_2)
		return Ryan.Vector.Magnitude(Ryan.Vector.Subtract(vector_1, vector_2))
	end,

	Magnitude = function(vector)
		return math.sqrt(vector.x ^ 2 + vector.y ^ 2 + vector.z ^ 2)
	end,

	Normalize = function(vector)
		return Ryan.Vector.Multiply(vector, 1 / Ryan.Vector.Magnitude(vector))
	end,

	RotationToDirection = function(rotation)
		rotation = { 
			x = (math.pi / 180) * rotation.x, 
			y = (math.pi / 180) * rotation.y, 
			z = (math.pi / 180) * rotation.z 
		}
		return {
			x = -math.sin(rotation.z) * math.abs(math.cos(rotation.x)), 
			y = math.cos(rotation.z) * math.abs(math.cos(rotation.x)), 
			z = math.sin(rotation.x)
		}
	end,

	DirectionToRotation = function(direction)
		return {
			x = math.asin(direction.z / Ryan.Vector.Magnitude(direction)) * (180 / math.pi),
			y = 0.0,
			z = -math.atan(direction.x, direction.y) * (180 / math.pi)
		}
	end,

	GetOffsetFromCamera = function(distance)
		local position = CAM.GET_FINAL_RENDERED_CAM_COORD()
		local rotation = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
		local direction = Ryan.Vector.RotationToDirection(rotation)
		local offset = {
			x = position.x + direction.x * distance,
			y = position.y + direction.y * distance,
			z = position.z + direction.z * distance 
		}
		return offset
	end,

	FromV3 = function(x, y, z)
		return {x = x, y = y, z = z}
	end,

	ToString = function(vector)
		return "{" .. math.floor(vector.x) .. ", " .. math.floor(vector.y) .. ", " .. math.floor(vector.z) .. "}"
	end
}