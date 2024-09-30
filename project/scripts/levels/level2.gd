extends Node2D

@onready var terrain_manager: Node2D = $TerrainManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain_manager.generate_terrain(13, FastNoiseLite.TYPE_PERLIN, 4, 0.0075)
	self.add_child(ParticleSimulation.new(200, 50, 0, 0))
