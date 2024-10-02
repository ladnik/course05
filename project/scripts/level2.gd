extends Node2D

@onready var terrain_manager: Node2D = $TerrainManager
var particle_simulation_resource = load("res://scenes/particle_simulation.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain_manager.generate_terrain(13, FastNoiseLite.TYPE_PERLIN, 4, 0.0075)
	var particle_simulation = particle_simulation_resource.instantiate()
	
	add_child(particle_simulation)
	particle_simulation.set_init_data(200, 50, 0, 0)

