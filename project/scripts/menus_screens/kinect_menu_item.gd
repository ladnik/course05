extends Label


var kinectEnabled: bool = false

var is_hovering: bool = false
var hover_time: float = 0

var is_enabled: bool = false

func _ready() -> void:
	self_modulate = Color(Color.DIM_GRAY)

func detectOverlap(pos: Vector2) -> bool:
	return (pos.x >= position[0]) and (pos.x <= position[0] + size[0]) and (pos.y >= position[1]) and (pos.y <= position[1] + size[1])

func getHoverTime() -> float:
	return hover_time

func _on_mouse_entered() -> void:
	is_hovering = true

func _on_mouse_exited() -> void:
	is_hovering = false

func enable() -> void:
	self_modulate = Color.WHITE
	is_enabled = true
	hover_time = 0

func disable() -> void:
	self_modulate = Color.DIM_GRAY
	is_enabled = false
	hover_time = 0

func _process(delta: float) -> void:
	var position = Vector2(0, 0) # position = kinect.getPosition()
	if is_hovering or detectOverlap(position):
		hover_time += delta
	else:
		hover_time = 0
