extends Control

@onready var video_feed = $VideoFeed
var kinect: GDKinect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	kinect = GDKinect.new()
	print(video_feed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	video_feed.texture = kinect.get_texture()
