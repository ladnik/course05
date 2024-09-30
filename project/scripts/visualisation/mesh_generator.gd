extends MeshInstance2D

const cases : Array = [
	[],
	[1, 2, 3],
	[3, 4, 5],								# 2
	[1, 2, 4, 1, 4, 5],
	[5, 6, 7],								# 4
	[1, 2, 3, 1, 3, 5, 1, 5, 7, 5, 6, 7],
	[3, 4, 6, 3, 6, 7],						# 6
	[1, 2, 4, 1, 4, 7, 4, 6, 7],
	[0, 1, 7],								# 8
	[0, 2, 3, 0, 3, 7],
	[0, 1, 7, 1, 5, 7, 1, 3, 5, 3, 4, 5],	# 10
	[0, 2, 7, 2, 5, 7, 2, 4, 5],
	[0, 1, 5, 0, 5, 6],						# 12
	[0, 2, 3, 0, 3, 5, 0, 5, 6],
	[0, 1, 6, 1, 3, 6, 3, 4, 6],			# 14
	[0, 2, 4, 0, 4, 6]
]

const border_cases : Array = [
	[],
	[[1, 3]],
	[[3, 5]],
	[[1, 5]],
	[[5, 7]],
	[[5, 3], [1, 7]],
	[[3, 7]],
	[[1, 7]],
	[[7, 1]],
	[[7, 3]],
	[[3, 1], [7, 5]],
	[[7, 5]],
	[[5, 1]],
	[[5, 3]],
	[[3, 1]],
	[]
]

var lines_in_cell : Array = []

var triangleCoordinates : PackedVector3Array = []
const caseLength : Array = [0, 1, 1, 2, 1, 4, 2, 3, 1, 2, 4, 3, 2, 3, 3, 2]
var cellTriangleIndex : Array[int] = []

var chunk_length = 40
var round_int_chunk : Array = []

var chunk_just_changed = []
var chunk_coords = []
var chunk_indices = []

var width = -1
var height = -1

var chunks_in_width = -1
var chunks_in_height = -1
# needed for collision debug drawing
@onready var renderer = $"../TerrainRenderer"
var debug_start_pos = Vector2(0, 0)
var debug_end_pos = Vector2(1, 1)
var debug_col = Vector2(0, 0)
var debug_normal = Vector2(1, 0)
var debug_collided : bool = false

func _ready():
	for i in range(chunk_length + 1):
		var row : Array = []
		row.resize(chunk_length + 1)
		round_int_chunk.append(row)

func visualize(grid : Array):

	# measured on Sascha's PC
	# Marching squares: 0.3s
	# Drawing triangles: 0.05s

	# with 8 neighbors:
	# Marching squares: 0.09s

	# with dynamic neighbors (and chunk_length = 40)
	# Marching squares: 0.05s
	
	# with int(roundf) extracted in front
	# Marching squares: 0.03s

	var start_ms = Time.get_unix_time_from_system()
	marchingSquares(grid)
	var end_ms = Time.get_unix_time_from_system()
	triangleMesh()
	var end_triangle_mesh =  Time.get_unix_time_from_system()

	# print("Marching Squares: ")
	# print(end_ms - start_ms)
	# print("Drawing: ")
	# print(end_triangle_mesh - end_ms)
	#queue_redraw() 

func _draw():
	#drawCollision()
	drawDebugCollision()
	pass #drawContours()

# Only for debugging
func drawContours():
	for i in range(0, triangleCoordinates.size(), 3):
		var vec1 = Vector2(triangleCoordinates[i].x, triangleCoordinates[i].y)
		var vec2 = Vector2(triangleCoordinates[i+1].x, triangleCoordinates[i+1].y)
		var vec3 = Vector2(triangleCoordinates[i+2].x, triangleCoordinates[i+2].y)

		var w = 0.2
		draw_line(vec1, vec2, Color.RED, w)
		draw_line(vec1, vec3, Color.RED, w)
		draw_line(vec3, vec2, Color.RED, w)

# Only for debugging
func drawCollision():
	for i in range(len(lines_in_cell)):
		for j in range(len(lines_in_cell[i])):
			for line in lines_in_cell[i][j]:
				var normal = line[2]
				var a = line[0]
				var b = line[1]
				var w = 0.2
				draw_line(a, b, Color.RED, w)
				draw_line(a, a + normal, Color(1, 0, 1))

func drawDebugCollision():
	var w = .5
	draw_line(renderer.to_grid_pos(debug_start_pos), renderer.to_grid_pos(debug_end_pos), Color(0, 1, 0), w)
	if debug_collided:
		draw_line(debug_col, debug_col + debug_normal, Color(1, 0, 1), w)

func triangleMesh():
	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = triangleCoordinates

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = arr_mesh

func get_triangles_per_chunk(chunk_idx_x, chunk_idx_y, grid: Array):

	var chunk_cell_triangle_index : Array[int] = []
	var chunk_triangle_coords : PackedVector3Array = []

	# triangleCoordinates = []
	# cellTriangleIndex = []
	# var height = len(grid)
	# var width = len(grid[0])
	if len(lines_in_cell) == 0:
		lines_in_cell.resize(len(grid) - 1)
		for i in range(len(grid) - 1):
			lines_in_cell[i] = []
			lines_in_cell[i].resize(len(grid[0]) - 1)

	var cellIndex = 0

	for y_in_chunk in range(chunk_length + 1):
		for x_in_chunk in range(chunk_length + 1):
			var y = y_in_chunk + chunk_idx_y * chunk_length
			var x = x_in_chunk + chunk_idx_x * chunk_length

			if x >= width - 1 or y >= height - 1:
				break

			round_int_chunk[y_in_chunk][x_in_chunk] = int(roundf(grid[y][x]))

	for y_in_chunk in range(chunk_length):
		for x_in_chunk in range(chunk_length):

			var y = y_in_chunk + chunk_idx_y * chunk_length
			var x = x_in_chunk + chunk_idx_x * chunk_length

			if x >= width - 1 or y >= height - 1:
				break

			# Determine bit number for cell
			var cellCase = ((round_int_chunk[y_in_chunk][x_in_chunk]) << 3) + ((round_int_chunk[y_in_chunk][x_in_chunk+1]) << 2) + ((round_int_chunk[y_in_chunk+1][x_in_chunk+1]) << 1) + round_int_chunk[y_in_chunk+1][x_in_chunk]
			var case = cases[cellCase]
			chunk_cell_triangle_index.append(cellIndex)
			cellIndex += caseLength[cellCase]
			for num in case:
				chunk_triangle_coords.append(marchingSquaresCoordinate(num, x, y, grid))
			
			lines_in_cell[y][x] = []
			var lines_to_add = border_cases[cellCase]
			for line in lines_to_add:
				var a : int = line[0]
				var a3 : Vector3 = marchingSquaresCoordinate(a, x, y, grid)
				var ap : Vector2 = Vector2(a3.x, a3.y)
				var b : int = line[1]
				var b3 : Vector3 = marchingSquaresCoordinate(b, x, y, grid)
				var bp : Vector2 = Vector2(b3.x, b3.y)
				var d : Vector2 = bp - ap
				var n : Vector2 = Vector2(d.y, -d.x).normalized()
				lines_in_cell[y][x].append([ap, bp, n])

	chunk_cell_triangle_index.append(cellIndex)

	return [chunk_cell_triangle_index, chunk_triangle_coords]

func set_chunk_and_neighbors_just_changed(mouse_pos_grid: Vector2, grid: Array, kernel_radius: float):

	var chunk_idx_x = int(mouse_pos_grid.x / chunk_length)
	var chunk_idx_y = int(mouse_pos_grid.y / chunk_length)

	var pos_from_chunk_x = mouse_pos_grid.x - chunk_idx_x * chunk_length
	var pos_from_chunk_y = mouse_pos_grid.y - chunk_idx_y * chunk_length 

	chunks_in_width = ceil(len(grid[0]) * 1.0 / chunk_length)
	chunks_in_height = ceil(len(grid) * 1.0 / chunk_length)

	var y_upper_offset = (2 if pos_from_chunk_y + kernel_radius >= chunk_length else 1)
	var x_upper_offset = (2 if pos_from_chunk_x + kernel_radius >= chunk_length else 1)
	var y_lower_offset = (-1 if pos_from_chunk_y - kernel_radius < 0 else 0)
	var x_lower_offset = (-1 if pos_from_chunk_x - kernel_radius < 0 else 0)

	for i in range(y_lower_offset, y_upper_offset):
		for j in range(x_lower_offset, x_upper_offset):

			chunk_just_changed[min(chunks_in_height - 1, max(0, chunk_idx_y + i))][min(chunks_in_width - 1, max(0, chunk_idx_x + j))] = 1


func marchingSquares(grid : Array):
	chunks_in_width = ceil(len(grid[0]) * 1.0 / chunk_length)
	chunks_in_height = ceil(len(grid) * 1.0 / chunk_length)

	# create caches
	if width == -1:
		
		for i in range(chunks_in_height):

			var chunk_row = []
			var chunk_index_row = []
			var chunk_just_changed_row = []

			for j in range(chunks_in_width):

				chunk_row.append([])
				chunk_index_row.append([])
				chunk_just_changed_row.append(true)
				
			print(len(chunk_just_changed_row))

			chunk_coords.append(chunk_row)
			chunk_just_changed.append(chunk_just_changed_row)
			chunk_indices.append(chunk_index_row)

	width = len(grid[0])
	height = len(grid)

	triangleCoordinates = []
	cellTriangleIndex = []

	for chunk_idx_y in range(chunks_in_height):
		for chunk_idx_x in range(chunks_in_width):

			if chunk_just_changed[chunk_idx_y][chunk_idx_x]:

				var res = get_triangles_per_chunk(chunk_idx_x, chunk_idx_y, grid)

				var chunk_cell_triangle_index = res[0]
				var chunk_triangle_coords = res[1]

				# write to cache
				chunk_coords[chunk_idx_y][chunk_idx_x] = chunk_triangle_coords
				chunk_indices[chunk_idx_y][chunk_idx_x] = chunk_cell_triangle_index
				
				chunk_just_changed[chunk_idx_y][chunk_idx_x] = false

			# retrieve from cache
			triangleCoordinates += chunk_coords[chunk_idx_y][chunk_idx_x]

			# TODO: offset the indices
			cellTriangleIndex += chunk_indices[chunk_idx_y][chunk_idx_x]

# Transform case into coordinate and add to coordinate list
func marchingSquaresCoordinate(num : int, x : int , y : int, grid : Array):

	var coord
	match num:
		0: 
			coord = Vector3(x, y, 0)
		1: 
			coord = Vector3(x, y + pointOffset(grid[y][x], grid[y+1][x]), 0)
		2: 
			coord = Vector3(x, y + 1, 0)
		3: 
			coord = Vector3(x + pointOffset(grid[y+1][x], grid[y+1][x+1]), y + 1, 0)
		4: 
			coord = Vector3(x + 1, y + 1, 0)
		5: 
			coord = Vector3(x + 1, y + pointOffset(grid[y][x+1], grid[y+1][x+1]), 0)
		6: 
			coord = Vector3(x + 1, y, 0)
		7: 
			coord = Vector3(x + pointOffset(grid[y][x], grid[y][x+1]), y, 0)
	
	return coord

func pointOffset(x0 : float, y0 : float):
	return (0.5 - x0) / (y0 - x0)


# Return a tuple 
func continuous_collision(start : Vector2, end : Vector2):
	start = renderer.to_grid_pos(start)
	end = renderer.to_grid_pos(end)
	var t_rs = []
	var collision_normals = []
	var x_min = int(min(start.x, end.x))
	var x_max = int(max(start.x, end.x)) + 1
	var y_min = int(min(start.y, end.y))
	var y_max = int(max(start.y, end.y)) + 1

	var v_r : Vector2 = -(end - start)
	var o_r : Vector2 = start

	for i in range(y_min, y_max):
		for j in range(x_min, x_max):
			var lines = lines_in_cell[i][j]
			for line in lines:
				var v_s : Vector2 = line[1] - line[0]
				var o_s : Vector2 = line[0]
				var b : Vector2 = o_r - o_s

				var t_r = -1.
				var t_s = -1.
				if v_s.x != 0:
					var tan_vs = v_s.y / v_s.x
					t_r = (b.y - tan_vs * b.x) / (v_r.y - tan_vs * v_r.x)
					t_s = (b.x - v_r.x * t_r) / v_s.x
				else:
					var inv_tan_vs = v_s.x / v_s.y
					t_r = (b.x - inv_tan_vs * b.y) / (v_r.x - inv_tan_vs * v_r.y)
					t_s = (b.y - v_r.y * t_r) / v_s.y

				# Collision occured
				if t_r >= 0 and t_r <= 1 and t_s >= 0 and t_s <= 1:
					t_rs.append(t_r)
					collision_normals.append(line[2])
	# no collisions occured
	if len(t_rs) == 0:
		# return a valid position and normalized normal vector to avoid strange errors
		return [false, Vector2(0, 0), Vector2(-1, 0)]

	var min_index = 0
	var min_distance = t_rs[0]
	for i in range(1, len(t_rs)):
		if t_rs[i] < min_distance:
			min_index = i
			min_distance = t_rs[i]
	return [true, o_r - v_r * min_distance, collision_normals[min_index]]



func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C:
			debug_start_pos = get_global_mouse_position()
		if event.pressed and event.keycode == KEY_V:
			debug_end_pos = get_global_mouse_position()
			var collision = continuous_collision(debug_start_pos, debug_end_pos)
			debug_collided = collision[0]
			debug_col = collision[1]
			debug_normal = collision[2]
			queue_redraw()
