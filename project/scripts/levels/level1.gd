extends Node2D

#signal select_immovable_terrain
#signal select_movable_terrain
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
	#self.add_child(particle_simulation)
	#$PowerPlant.set_particle_simulation(particle_simulation)
	
	#select_movable_terrain.connect(terrain_manager.on_select_movable_terrain)
	#select_immovable_terrain.connect(terrain_manager.on_select_immovable_terrain)
	
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("select_movable_terrain"):
		#select_movable_terrain.emit()
	#if Input.is_action_just_pressed("select_immovable_terrain"):
		#select_immovable_terrain.emit()
