extends Node2D

@onready var terrain_manager: Node2D = $TerrainManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_water_sound()
	terrain_manager.generate_terrain(0815, FastNoiseLite.TYPE_PERLIN, 4, 0.0075)
	var particle_simulation = ParticleSimulation.new(100, 200, 100, 200)
	self.add_child(particle_simulation)
	$PowerPlant.set_particle_simulation(particle_simulation)

# Called when the node is removed from the scene tree
func _exit_tree() -> void:
	AudioManager.stop_water_sound()  # Stop water music when exiting the level
	

func _input(event: InputEvent) -> void:
	# Handle RMB (digging)
	if event.is_action_pressed("mouse_right"):  # Right mouse button pressed
		AudioManager.start_digging()  # Start playing the dig sound and loop if held
	elif event.is_action_released("mouse_right"):  # Right mouse button released
		AudioManager.stop_digging()  # Stop looping but finish the last cycle

	# Handle LMB (building)
	if event.is_action_pressed("mouse_left"):  # Left mouse button pressed
		AudioManager.start_building()  # Start playing the build sound and loop if held
	elif event.is_action_released("mouse_left"):  # Left mouse button released
		AudioManager.stop_building()  # Stop looping but finish the last cycle
