extends Node2D

func _draw():
	draw_debug_collision()

func draw_debug_collision():
	var w = 2
	draw_line(renderer.to_grid_pos(debug_start_pos), renderer.to_grid_pos(debug_end_pos), Color(0, 1, 0), w)
	if debug_collided:
		draw_line(debug_col, debug_col + debug_normal, Color(1, 0, 1), w)

func draw_debug_points():
	draw_line(debug_col, debug_col + debug_normal, Color(1, 0, 1), 2)
	for point in debug_output:
		draw_circle(point * 8, 5, Color.RED)

@onready var renderer = $"../TerrainRenderer"
@onready var geom = $"../MeshGenerator"
var debug_start_pos = Vector2(0, 0)
var debug_end_pos = Vector2(1, 1)
var debug_col = Vector2(0, 0)
var debug_normal = Vector2(1, 0)
var debug_collided : bool = false
var debug_output : Array

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C:
			debug_start_pos = get_global_mouse_position()
		if event.pressed and event.keycode == KEY_V:
			debug_end_pos = get_global_mouse_position()
			var collision = geom.continuous_collision(debug_start_pos / 8, debug_end_pos / 8)
			debug_collided = collision[0]
			debug_col = collision[1]
			debug_normal = collision[2]
			print(debug_collided)
			debug_output = collision
			queue_redraw()