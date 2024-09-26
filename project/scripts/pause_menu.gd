extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = not visible

func resume_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().paused = false
		visible = false

func exit_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().quit()

func menu_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
