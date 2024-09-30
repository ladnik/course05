extends CanvasLayer

@export var terrain_manager: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = not visible
		terrain_manager.editor.terraforming_blocked = not terrain_manager.editor.terraforming_blocked
		

func resume_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		visible = false
		get_tree().paused = not get_tree().paused
		await get_tree().create_timer(0.1).timeout
		terrain_manager.editor.terraforming_blocked = not terrain_manager.editor.terraforming_blocked

func exit_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().quit()

func menu_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().paused = false
		TransitionScene.transition_effect("res://scenes/menus_screens/menu.tscn")


func _on_replay_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().paused = false
		TransitionScene.transition_effect_for_reload()
