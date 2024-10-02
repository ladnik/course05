extends Node2D

@onready var immovable_zones: Node2D = $ImmovableZones
@onready var terrain_manager: Node2D = $TerrainManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rects = []
	for child in immovable_zones.get_children():
		var global_rect = child.get_global_rect()
		
		var pos = terrain_manager.mesh_generator.to_grid_pos(global_rect.position)
		var end = terrain_manager.mesh_generator.to_grid_pos(global_rect.end)
		
		rects.append([pos, end])
	terrain_manager.generate_terrain(0815, FastNoiseLite.TYPE_PERLIN, 4, 0.0075, rects)
	var particle_simulation = ParticleSimulation.new(100, 200, 100, 200)
	self.add_child(particle_simulation)
	$PowerPlant.set_particle_simulation(particle_simulation)
	
