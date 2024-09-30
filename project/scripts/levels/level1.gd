extends Node2D

@onready var terrain_manager: Node2D = $TerrainManager
@onready var power_plant: Node2D = $PowerPlant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain_manager.generate_terrain(0815, FastNoiseLite.TYPE_PERLIN, 4, 0.0075)
	var particle_simulation = ParticleSimulation.new(100, 200, 100, 200)
	self.add_child(particle_simulation)
	$PowerPlant.set_particle_simulation(particle_simulation)
