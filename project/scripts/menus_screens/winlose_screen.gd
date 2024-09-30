extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_nextlevel_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		print(get_tree().get_current_scene())
		TransitionScene.transition_effect("res://scenes/levels/level2.tscn")


func _on_replay_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/levels/level1.tscn")


func _on_mainmenu_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/menus_screens/menu.tscn")
