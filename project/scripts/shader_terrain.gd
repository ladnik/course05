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
	var center_point = (start + end) / 2
	var cell_i = floor(center_point.y)
	var cell_j = floor(center_point.x)


func continuous_collision(start : Vector2, end : Vector2):
	var delta = end - start
	var horizontal_plane_distances = whole_level_distances(start.y, end.y, delta.y)
	var vertical_plane_distances = whole_level_distances(start.x, end.x, delta.x)
	var all_distances = [0] + horizontal_plane_distances + vertical_plane_distances + [1]
	all_distances.sort()

	var local_start = start
	for segment in range(len(all_distances) - 1):
		local_end = start + all_distances[segment + 1] * delta
		collision = continuous_collision_local(local_start, local_end)
		if collision[0]:
			return collision

	return [false, Vector2(0, 0), Vector2(1, 0)]


