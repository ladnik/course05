extends Node2D

# import terrrain manager script to access the terrain data
const TERRAIN_MANAGER = preload("res://scripts/terrain_manager.gd")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var terrain_manager = TERRAIN_MANAGER.new()
	var boundaries = terrain_manager.generateGrid()
	print(boundaries)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
