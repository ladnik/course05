extends Node2D

@onready var editor = $TerrainEditor
@onready var renderer = $TerrainRenderer
@onready var mesh_generator = $MeshGenerator

# Godot functions

var last_mouse_clicked = false
var this_mouse_clicked = false

var only_marching_squares_after_drawn = false

# called by Level1 with level params
func generate_terrain(seed, type, octaves, frequency):
	editor.generateGrid(seed, type, octaves, frequency)
	renderer.initialize(editor.grid, mesh_generator.scale)
	mesh_generator.visualize(editor.grid)
	

func _process(_delta):
	var mouse_pos_grid = renderer.to_grid_pos(get_global_mouse_position())

	this_mouse_clicked = false

	# place new terrain
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and editor.on_grid(mouse_pos_grid):
		editor.apply_kernel(mouse_pos_grid, 1.0)
		renderer.update_grid(editor.grid)
		mesh_generator.set_chunk_and_neighbors_just_changed(mouse_pos_grid, editor.grid, editor.kernel_radius)
		this_mouse_clicked = true

		if not only_marching_squares_after_drawn:
			mesh_generator.visualize(editor.grid)
		
	# remove terrain
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and editor.on_grid(mouse_pos_grid):
		editor.apply_kernel(mouse_pos_grid, 0.0)
		mesh_generator.set_chunk_and_neighbors_just_changed(mouse_pos_grid, editor.grid, editor.kernel_radius)
		renderer.update_grid(editor.grid)
		this_mouse_clicked = true

		if not only_marching_squares_after_drawn:
			mesh_generator.visualize(editor.grid)

	if !this_mouse_clicked and last_mouse_clicked and only_marching_squares_after_drawn:
		print("just released")
		mesh_generator.visualize(editor.grid)

	last_mouse_clicked = this_mouse_clicked

	

	
