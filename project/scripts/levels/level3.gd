extends Node2D

@onready var terrain_manager: Node2D = $TerrainManager
@onready var power_plant: PowerPlant = $PowerPlant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain_manager.generate_terrain(13276, FastNoiseLite.TYPE_PERLIN, 4, 0.0075)
	var particle_simulation = ParticleSimulation.new(300, 50, 0, 0)
	self.add_child(particle_simulation)
	
	power_plant.set_particle_simulation(particle_simulation)
	power_plant.enough_water_flow.connect(_on_enough_water)

func _on_enough_water() -> void:
	if power_plant.done:
		# Check the previous scene from TransitionScene
		var prev_scene = TransitionScene.prevscene

		# Print the previous scene for debugging
		print("Previous Scene: " + prev_scene)

		# Determine what to do based on the previous scene
		if prev_scene == "res://scenes/levels/level1.tscn":
			print("Transitioning from Level 1 to Win Screen")
			TransitionScene.transition_effect("res://scenes/menus_screens/win_screen.tscn")
		elif prev_scene == "res://scenes/levels/level2.tscn":
			print("Transitioning from Level 2 to Win Screen")
			TransitionScene.transition_effect("res://scenes/menus_screens/win_screen.tscn")
		elif prev_scene == "res://scenes/levels/level3.tscn":
			print("Transitioning from Level 3 to After Final Level Screen")
			TransitionScene.transition_effect("res://scenes/menus_screens/after_final_level.tscn")
