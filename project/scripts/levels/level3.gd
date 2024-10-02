extends Node2D

@onready var immovable_zones: Node2D = $ImmovableZones
@onready var terrain_manager: Node2D = $TerrainManager
@onready var power_plant: PowerPlant = $PowerPlant
@onready var village: Node2D = $Village
@onready var lose_screen: CanvasLayer = $lose_screen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain_manager.generate_terrain(3, FastNoiseLite.TYPE_PERLIN, 4, 0.0075, get_immovable_rects())
	var particle_simulation = ParticleSimulation.new(300, 50, 0, 0)
	self.add_child(particle_simulation)
	
	power_plant.set_particle_simulation(particle_simulation)
	power_plant.enough_water_flow.connect(_on_enough_water)
	
	village.set_particle_simulation(particle_simulation)
	village.village_destroyed.connect(_on_village_destroyed)

func _on_enough_water() -> void:
	if power_plant.done:
		# Check the previous scene from TransitionScene
		var prev_scene = TransitionScene.prevscene
		TransitionScene.transition_effect("res://scenes/menus_screens/after_final_level.tscn")

func _on_village_destroyed() -> void:
	TransitionScene.transition_effect("res://scenes/menus_screens/lose_screen.tscn")

func get_immovable_rects() -> Array:
	var rects = []
	for child in immovable_zones.get_children():
		var global_rect = child.get_global_rect()
		
		var pos = terrain_manager.mesh_generator.to_grid_pos(global_rect.position)
		var end = terrain_manager.mesh_generator.to_grid_pos(global_rect.end)
		
		rects.append([pos, end])
	return rects