extends CanvasLayer

func _on_level1_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/menus_screens/tutorial.tscn")


func _on_backtomainmenu_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/menus_screens/menu.tscn")

func _on_level_2_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/levels/level2.tscn")


func _on_play_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/levels/level1.tscn")
