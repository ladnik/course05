extends Node2D

@onready var editor = $TerrainEditor
@onready var renderer = $TerrainRenderer
@onready var mesh_generator = $MeshGenerator

# Godot functions

var kinect: GDKinect
var last_mouse_clicked = false
var this_mouse_clicked = false

var kinect_enabled: bool = false
enum KinectMode {DRAW, REMOVE, NONE}
var kinect_mode: KinectMode = KinectMode.NONE

var only_marching_squares_after_drawn = false

# called by Level with level params
func generate_terrain(seed, type, octaves, frequency, immovable_rects: Array):
	editor.generateGrid(seed, type, octaves, frequency, immovable_rects)
	renderer.initialize(editor.grid, mesh_generator.scale)
	mesh_generator.visualize(editor.grid)

func _ready():
	kinect = GDKinect.new()

func _process(_delta):
	var mouse_pos = kinect.get_position() if kinect_enabled else get_global_mouse_position()
	var mouse_pos_grid = renderer.to_grid_pos(mouse_pos)

	this_mouse_clicked = false

	# place new terrain
	if input_draw_mode() and editor.on_grid(mouse_pos_grid):
		editor.apply_kernel(mouse_pos_grid, 1.0)
		renderer.update_grid(editor.grid)
		mesh_generator.set_chunk_and_neighbors_just_changed(mouse_pos_grid, editor.grid, editor.kernel_radius)
		this_mouse_clicked = true

		if not only_marching_squares_after_drawn:
			mesh_generator.visualize(editor.grid)
		
	# remove terrain
	if input_remove_mode() and editor.on_grid(mouse_pos_grid):
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

func input_draw_mode():
	(kinect_enabled && kinect_mode == KinectMode.DRAW && false) || (!kinect_enabled && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))

func input_remove_mode():
	(kinect_enabled && kinect_mode == KinectMode.REMOVE && false) || (!kinect_enabled && Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))
