extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		get_tree().paused = false
		visible = false
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		visible = true
