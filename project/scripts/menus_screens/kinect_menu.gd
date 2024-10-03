extends CanvasLayer

@export var drawButton: Label
@export var removeButton: Label

@export var terrain_manager: Node2D

var kinectEnabled: bool = false

const THRESHOLD: float = 0.2

var draw_time: float
var remove_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	drawButton.terrain_manager = terrain_manager
	removeButton.terrain_manager = terrain_manager
	drawButton.enable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if terrain_manager.kinect_enabled:
		visible = true
		$Overlay.position = terrain_manager.kinect.get_position()
		#Input.warp_mouse(terrain_manager.kinect.get_position())
	else:
		visible = false

	draw_time = drawButton.getHoverTime()
	remove_time = removeButton.getHoverTime()
	
	if draw_time > THRESHOLD:
		match terrain_manager.kinect_mode:
			terrain_manager.KinectMode.DRAW:
				drawButton.disable()
				terrain_manager.kinect_mode = terrain_manager.KinectMode.NONE
			terrain_manager.KinectMode.REMOVE:
				removeButton.disable()
				drawButton.enable()
				terrain_manager.kinect_mode = terrain_manager.KinectMode.DRAW
			terrain_manager.KinectMode.NONE:
				drawButton.enable()
				terrain_manager.kinect_mode = terrain_manager.KinectMode.DRAW
	if remove_time > THRESHOLD:
		match terrain_manager.kinect_mode:
			terrain_manager.KinectMode.DRAW:
				drawButton.disable()
				removeButton.enable()
				terrain_manager.kinect_mode = terrain_manager.KinectMode.REMOVE
			terrain_manager.KinectMode.REMOVE:
				removeButton.disable()
				terrain_manager.kinect_mode = terrain_manager.KinectMode.NONE
			terrain_manager.KinectMode.NONE:
				removeButton.enable()
				terrain_manager.kinect_mode = terrain_manager.KinectMode.REMOVE
