extends Label

var time_elapsed = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	var m = int(time_elapsed / 60)
	var s = int(time_elapsed - m * 60)
	var ms = int((time_elapsed - s - m * 60) * 1000)
	text = str(m) + ":" + str(s) + ":" + str(ms)

	
