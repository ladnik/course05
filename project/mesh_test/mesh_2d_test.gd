extends MeshInstance2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vertices = PackedVector3Array()
	vertices.push_back(Vector3(0, 100, 0))
	vertices.push_back(Vector3(100, 0, 0))
	vertices.push_back(Vector3(0, 0, 100))

	var vertices2 = PackedVector3Array()
	vertices.push_back(Vector3(300, 0, 0))
	vertices.push_back(Vector3(0,300,0))
	vertices.push_back(Vector3(300, 300,  0))

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	var arrays2 = []
	arrays2.resize(Mesh.ARRAY_MAX)
	arrays2[Mesh.ARRAY_VERTEX] = vertices2

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays2)
	mesh = arr_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
