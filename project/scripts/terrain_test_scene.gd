extends Node2D

@onready var marching_squares = $MarchingSquares
@onready var terrain_manager = $TerrainManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	marching_squares.visualize(terrain_manager.grid, terrain_manager.height, terrain_manager.width)
