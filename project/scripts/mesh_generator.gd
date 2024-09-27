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

# needed for collision debug drawing
@onready var renderer = $"../TerrainRenderer"
var debug_start_pos = Vector2(0, 0)
var debug_end_pos = Vector2(1, 1)
var debug_col = Vector2(0, 0)
var debug_normal = Vector2(1, 0)
var debug_collided : bool = false

func visualize(grid : Array):
	marchingSquares(grid)
	triangleMesh()
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
	draw_line(debug_start_pos, debug_end_pos, Color(0, 1, 0), w)
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

func marchingSquares(grid : Array):
	
	triangleCoordinates = []
	cellTriangleIndex = []
	var height = len(grid)
	var width = len(grid[0])
	if len(lines_in_cell) == 0:
		lines_in_cell.resize(height - 1)
		for i in range(height - 1):
			lines_in_cell[i] = []
			lines_in_cell[i].resize(width - 1)

	var cellIndex = 0
	for y in range(height - 1):
		for x in range(width - 1):
			# Determine bit number for cell
			var cellCase = (int(!!roundf(grid[y][x])) << 3) + (int(!!roundf(grid[y][x+1])) << 2) + (int(!!roundf(grid[y+1][x+1])) << 1) + int(!!roundf(grid[y+1][x]))
			var case = cases[cellCase]
			cellTriangleIndex.append(cellIndex)
			cellIndex += caseLength[cellCase]
			for num in case:
				triangleCoordinates.append(marchingSquaresCoordinate(num, x, y, grid))
			
			
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

	cellTriangleIndex.append(cellIndex)


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
			debug_start_pos = renderer.to_grid_pos(get_global_mouse_position())
		if event.pressed and event.keycode == KEY_V:
			debug_end_pos = renderer.to_grid_pos(get_global_mouse_position())
			var collision = continuous_collision(debug_start_pos, debug_end_pos)
			debug_collided = collision[0]
			debug_col = collision[1]
			debug_normal = collision[2]
			queue_redraw()
