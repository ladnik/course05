extends MeshInstance2D

var cases : Array = [
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
var triangleCoordinates : PackedVector3Array = []
var caseLength : Array = [0, 1, 1, 2, 1, 4, 2, 3, 1, 2, 4, 3, 2, 3, 3, 2]
var cellTriangleIndex : Array[int] = []

func visualize(grid : Array, height : int, width : int):
	marchingSquares(grid, height, width)
	triangleMesh()
	queue_redraw()

func _draw():
	pass #drawContours()

func drawContours():
	for i in range(0, triangleCoordinates.size(), 3):
		var vec1 = Vector2(triangleCoordinates[i].x, triangleCoordinates[i].y)
		var vec2 = Vector2(triangleCoordinates[i+1].x, triangleCoordinates[i+1].y)
		var vec3 = Vector2(triangleCoordinates[i+2].x, triangleCoordinates[i+2].y)

		var w = 0.2
		draw_line(vec1, vec2, Color.RED, w)
		draw_line(vec1, vec3, Color.RED, w)
		draw_line(vec3, vec2, Color.RED, w)

func triangleMesh():
	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = triangleCoordinates

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var m = MeshInstance3D.new()
	mesh = arr_mesh


func marchingSquares(grid : Array, height : int, width : int):
	var cellIndex = 0
	for y in range(height - 1):
		for x in range(width - 1):
			# Determine bit number for cell
			var cellCase = (int(!!roundf(grid[y][x])) << 3) + (int(!!roundf(grid[y][x+1])) << 2) + (int(!!roundf(grid[y+1][x+1])) << 1) + int(!!roundf(grid[y+1][x]))
			var case = cases[cellCase]
			cellTriangleIndex.append(cellIndex)
			cellIndex += caseLength[cellCase]
			for num in case:
				marchingSquaresCoordinate(num, x, y, grid)
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
	triangleCoordinates.append(coord)

func pointOffset(x0 : float, y0 : float):
	return (0.5 - x0) / (y0 - x0)
