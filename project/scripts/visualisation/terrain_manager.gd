extends Node2D

@onready var editor = $TerrainEditor
@onready var renderer = $TerrainRenderer
@onready var mesh_generator = $MeshGenerator
@onready var KernelRadius : Sprite2D = $KernelRadius

var showKernelRadiusTimer = 0.;
var kernelRadiusShowTime = 0.5;

var initialKernelRadius = 5

# Godot functions

var last_mouse_clicked = false
var this_mouse_clicked = false

var only_marching_squares_after_drawn = false

var mouse_position = null

# called by Level with level params
func generate_terrain(seed, type, octaves, frequency, immovable_rects: Array):
	editor.generateGrid(seed, type, octaves, frequency, immovable_rects)
	renderer.initialize(editor.grid, mesh_generator.scale)
	mesh_generator.visualize(editor.grid)

func load_terrain(grid, immovable_rects: Array):
	editor.loadGrid(grid, immovable_rects)
	renderer.initialize(editor.grid, mesh_generator.scale)
	mesh_generator.visualize(editor.grid)
	

func _process(_delta):
	
	var mouse_pos_grid = renderer.to_grid_pos(get_global_mouse_position())

	this_mouse_clicked = false
	
	if Input.is_action_just_pressed("wheel_up"):
		editor.kernel_radius *= 1.25
		showKernelRadiusTimer = kernelRadiusShowTime
		
		
	if Input.is_action_just_pressed("wheel_down"):
		editor.kernel_radius *= 0.75
		showKernelRadiusTimer = kernelRadiusShowTime

	editor.kernel_radius = clamp(editor.kernel_radius, 0.25 * initialKernelRadius, 2 * initialKernelRadius)

	showKernelRadiusTimer -= _delta

	KernelRadius.position = get_global_mouse_position()
	KernelRadius.scale = Vector2(1.0, 1.0) * editor.kernel_radius * 15.0 / 132
	KernelRadius.modulate = Color(1, 1, 1, showKernelRadiusTimer / kernelRadiusShowTime)

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
		#print("just released")
		mesh_generator.visualize(editor.grid)

	last_mouse_clicked = this_mouse_clicked
	
func _draw():
	#draw_circle(get_global_mouse_position(), editor.kernel_radius * 15, Color.BLACK)
	#queue_redraw()
	pass
	

	
