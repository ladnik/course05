extends MeshInstance2D

var cases : Array = [
	[],
	[1, 2, 3],
	[3, 4, 5],
	[1, 2, 4, 1, 4, 5],
	[5, 6, 7],
	[1, 2, 3, 1, 3, 5, 1, 5, 7, 5, 6, 7],
	[3, 4, 6, 4, 6, 7],
	[1, 2, 4, 1, 4, 7, 4, 6, 7],
	[0, 1, 7],
	[0, 2, 3, 0, 3, 7],
	[0, 1, 7, 1, 5, 7, 1, 3, 5, 3, 4, 5],
	[0, 2, 7, 2, 5, 7, 2, 4, 5],
	[0, 1, 5, 0, 5, 6],
	[0, 2, 3, 0, 3, 5, 0, 5, 6],
	[0, 1, 6, 1, 3, 6, 3, 4, 5],
	[0, 2, 4, 0, 4, 6]
]
var triangleCoordinates : PackedVector3Array = []

func visualize(grid : Array, height : int, width : int):
	marchingSquares(grid, height, width)
	triangleMesh()

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
	for y in range(height - 1):
		for x in range(width - 1):
			# Determine bit number for cell
			var cellCase = (int(!!grid[y][x]) << 3) + (int(!!(grid[y][x+1])) << 2) + (int(!!(grid[y+1][x+1])) << 1) + int(!!(grid[y+1][x]))
			var case = cases[cellCase]
			for num in case:
				marchingSquaresCoordinate(num, x, y)

# Transform case into coordinate and add to coordinate list
func marchingSquaresCoordinate(num : int, x : int , y : int):
	var coord
	match num:
		0: 
			coord = Vector3(x, y, 0)
		1: 
			coord = Vector3(x, y + 0.5, 0)
		2: 
			coord = Vector3(x, y + 1, 0)
		3: 
			coord = Vector3(x + 0.5, y + 1, 0)
		4: 
			coord = Vector3(x + 1, y + 1, 0)
		5: 
			coord = Vector3(x + 1, y + 0.5, 0)
		6: 
			coord = Vector3(x + 1, y, 0)
		7: 
			coord = Vector3(x + 0.5, y, 0)
	triangleCoordinates.append(coord)
