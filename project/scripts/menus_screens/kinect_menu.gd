extends CanvasLayer

@onready var drawButton = get_node("Draw")
@onready var removeButton = get_node("Remove")

var kinectEnabled: bool = false

const THRESHOLD: float = 2

var draw_time: float
var remove_time: float

enum KinectMode {DRAW, REMOVE, NONE}
var current_mode: KinectMode = KinectMode.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drawButton.visible = false
	removeButton.visible = false
	$Enable.self_modulate = Color.DIM_GRAY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	draw_time = drawButton.getHoverTime()
	remove_time = removeButton.getHoverTime()
	
	
	
	if draw_time > THRESHOLD:
		match current_mode:
			KinectMode.DRAW:
				drawButton.disable()
				current_mode = KinectMode.NONE
			KinectMode.REMOVE:
				removeButton.disable()
				drawButton.enable()
				current_mode = KinectMode.DRAW
			KinectMode.NONE:
				drawButton.enable()
				current_mode = KinectMode.DRAW
	if remove_time > THRESHOLD:
		match current_mode:
			KinectMode.DRAW:
				drawButton.disable()
				removeButton.enable()
				current_mode = KinectMode.REMOVE
			KinectMode.REMOVE:
				removeButton.disable()
				current_mode = KinectMode.NONE
			KinectMode.NONE:
				removeButton.enable()
				current_mode = KinectMode.REMOVE
	



func _on_enable(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		kinectEnabled = not kinectEnabled
	
	if kinectEnabled:
		drawButton.visible = true
		removeButton.visible = true
		$Enable.self_modulate = Color.WHITE
	else:
		drawButton.visible = false
		removeButton.visible = false
		$Enable.self_modulate = Color.DIM_GRAY
		
