extends CanvasLayer

@export var drawButton: Label
@export var removeButton: Label

@export var terrain_manager: Node2D

var kinectEnabled: bool = false

const THRESHOLD: float = 0.5

var draw_time: float
var remove_time: float

enum KinectMode {DRAW, REMOVE, NONE}
var current_mode: KinectMode = KinectMode.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if terrain_manager.kinect_enabled:
		visible = true
	else:
		visible = false
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
