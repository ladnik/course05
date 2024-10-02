extends Sprite2D

@onready var renderer = $"../TerrainRenderer"
var stored_grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func visualize(grid : Array) -> void:
	stored_grid = grid
	var img = Image.create(len(grid[0]), len(grid), false, Image.FORMAT_R8)  # Create a 256x256 single channel image (8-bit)

	for y in range(len(grid)):
		for x in range(len(grid[0])):
			img.set_pixel(x, y, Color(grid[y][x], 0, 0, 1))

	var itex = ImageTexture.create_from_image(img)
	self.texture = itex
	material.set_shader_parameter("x_size", len(grid[0]) - 1)
	material.set_shader_parameter("y_size", len(grid) - 1)

	position.x = len(grid[0]) / 2 * 8
	position.y = len(grid) / 2*8
	scale.x = 8
	scale.y = 8


var debug_start_pos = Vector2(0, 0)
var debug_end_pos = Vector2(1, 1)
var debug_col = Vector2(0, 0)
var debug_normal = Vector2(1, 0)
var debug_collided : bool = false

func bilinear(pos : Vector2):
	var x_low = min(max(floor(pos.x), 0), len(stored_grid[0]) - 2)
	var x_high = max(min(ceil(pos.x), len(stored_grid[0]) - 1), 1)
	if x_high == x_low:
		x_high = x_high + 1
	var x_t = pos.x - x_low
	var y_low = min(max(floor(pos.y), 0), len(stored_grid) - 2)
	var y_high = max(min(ceil(pos.y), len(stored_grid) - 1), 1)
	if y_high == y_low:
		y_high = y_high + 1
	var y_t = pos.y - y_low

	var at_y_low = lerp(stored_grid[y_low][x_low], stored_grid[y_low][x_high], x_t)
	var at_y_high = lerp(stored_grid[y_high][x_low], stored_grid[y_high][x_high], x_t)

	return lerp(at_y_low, at_y_high, y_t)

func point_collision(pos : Vector2):
	return bilinear(pos) > .5

func whole_level_distances(start, end, delta):
	var distances = []
	var small = ceil(min(start, end))
	if small == min(start, end):
		small += 1
	var large = floor(max(start, end))
	if large == max(start, end):
		large -= 1
	
	for v in range(small, large + 1):
		distances.append((v - start) / delta)
	return distances

# helper function to be called on points in the same cell
func continuous_collision_local(start, end):
	var center = (start + end) / 2
	var x_low = min(max(floor(center.x), 0), len(stored_grid[0]) - 2)
	var x_high = max(min(ceil(center.x), len(stored_grid[0]) - 1), 1)
	if x_high == x_low:
		x_high = x_high + 1
	var y_low = min(max(floor(center.y), 0), len(stored_grid) - 2)
	var y_high = max(min(ceil(center.y), len(stored_grid) - 1), 1)
	if y_high == y_low:
		y_high = y_high + 1

	var a = stored_grid[y_low][x_low]
	var b = stored_grid[y_low][x_high]
	var c = stored_grid[y_high][x_high]
	var d = stored_grid[y_high][x_low]
	var e = b - a
	var f = c - d

	var o_x = start.x - x_low
	var o_y = start.y - y_low
	var otilde_y = 1 - o_y
	var delta = end - start
	var delta_x = delta.x
	var delta_y = delta.y
	

	var A = delta_x * delta_y * (f - e)
	var B = delta_x * (otilde_y * e + o_y * f) + delta_y * (d + f * o_x - a - e * o_x)
	var C = otilde_y * a + otilde_y * e * o_x + o_y * d + o_y * f * o_x - .5
	if A != 0:
		var determinant = B * B - 4 * A * C
		print([A, B, C, determinant])
		if determinant < 0:
			return [false, Vector2(0, 0), Vector2(1, 0)]
		var rt = pow(B * B - 4 * A * C, .5)
		var solution_small = (-B - rt) / 2 / A
		var solution_large = (-B + rt) / 2 / A
		if solution_small > 0:
			return [true, start + solution_small * delta, Vector2(1, 0)]
		if solution_large > 0:
			return [true, start + solution_large * delta, Vector2(1, 0)]
		return [false, Vector2(0, 0), Vector2(1, 0)]

	var t = -C / b
	if t >= 0 and t <= 1:
		return [true, start + t * delta, Vector2(1, 0)]
	return [false, Vector2(0, 0), Vector2(1, 0)]

func continuous_collision(start : Vector2, end : Vector2):
	var delta = end - start
	var horizontal_plane_distances = whole_level_distances(start.y, end.y, delta.y)
	var vertical_plane_distances = whole_level_distances(start.x, end.x, delta.x)
	var all_distances = [0] + horizontal_plane_distances + vertical_plane_distances + [1]
	all_distances.sort()

	var local_start = start
	for segment in range(len(all_distances) - 1):
		var local_end = start + all_distances[segment + 1] * delta
		var collision = continuous_collision_local(local_start, local_end)
		if collision[0]:
			return collision
		local_start = local_end

	return [false, Vector2(0, 0), Vector2(1, 0)]


