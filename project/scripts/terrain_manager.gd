extends Node2D

const Editor = preload("res://scripts/terrain_editor.gd")
const Renderer = preload("res://scripts/terrain_renderer.gd")
 
var editor
var renderer

# Godot functions

func _ready():
	editor = Editor.new()
	renderer = Renderer.new()
	
	editor.generateGrid()	
	renderer.initialize(editor.grid)

func _process(_delta):
	var mouse_pos_grid = renderer.to_grid_pos(get_global_mouse_position())

	# place new terrain
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and editor.on_grid(mouse_pos_grid):
		editor.apply_kernel(mouse_pos_grid, 1.0)
		renderer.update_grid(editor.grid)
		
	# remove terrain
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and editor.on_grid(mouse_pos_grid):
		editor.apply_kernel(mouse_pos_grid, 0.0)
		renderer.update_grid(editor.grid)	
