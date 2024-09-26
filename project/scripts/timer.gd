extends Label

var time_elapsed = 0.0

func _ready() -> void:
	Engine.time_scale = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	var m = int(time_elapsed / 60)
	var s = int(time_elapsed - m * 60)
	var ms = int((time_elapsed - s - m * 60) * 1000)
	text = str(m) + ":" + str(s) + ":" + str(ms)
	
	if Input.is_action_pressed("start"):
		Engine.time_scale = 1
	if Input.is_action_pressed("pause"):
		Engine.time_scale = 0
	
