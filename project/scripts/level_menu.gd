extends CanvasLayer

func _on_level1_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().change_scene_to_file("res://scenes/level1.tscn")


func _on_backtomainmenu_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_level_2_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().change_scene_to_file("res://scenes/level2.tscn")
