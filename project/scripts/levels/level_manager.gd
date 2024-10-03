extends Node2D

class_name LevelManager

@onready var terrain_manager: Node2D = $TerrainManager

var immovable_zones: Array
var villages: Array
var power_plants: Array 

@export_group("Terrain Generation Properties")

@export var seed : int = 815
@export var type : FastNoiseLite.NoiseType = FastNoiseLite.TYPE_PERLIN
@export var octaves : int = 4
@export var frequency : float = 0.0075

#Particle simulation settings
@export_group("Particle Simulation Properties")
@export var pos_x : int = 100
@export var dis_x : int = 200
@export var pos_y : int = 100
@export var dis_y : int = 200
@export var vel_x : int = 0
@export var vel_y : int = 500
@export var mass_flow : int = 5
@export var number_particles: int = 500

@export_group("")
@export var path : String = "res://assets/levels/level1.lvl"
@export var do_load_level : bool = false


func _ready() -> void:
	if do_load_level:
		load_level()
	else:
		generate_level()

func load_level():
	terrain_manager.load_terrain(load_grid(), get_immovable_rects())
	initialize()

func generate_level():
	terrain_manager.generate_terrain(seed, type, octaves, frequency, get_immovable_rects())
	initialize()
		

func initialize(): 
	var particle_simulation = load("res://scenes/simulation/particle_simulation.tscn").instantiate()
	self.add_child(particle_simulation)
	AudioManager.play_gong_sound()
	particle_simulation.set_water_source(pos_x, dis_x, pos_y, dis_y, vel_x, vel_y, mass_flow, number_particles)

	AudioManager.play_water_sound()
	
	#Initialize power plants
	if $PowerPlants != null:
		power_plants = $PowerPlants.get_children()
		for power_plant in power_plants:
			power_plant.set_particle_simulation(particle_simulation)
			power_plant.enough_water_flow.connect(_on_enough_water)
	
	#Initialize villages
	if $Villages != null:
		villages = $Villages.get_children()
		for village in villages:
			village.set_particle_simulation(particle_simulation)
			village.village_destroyed.connect(_on_village_destroyed)

func _on_enough_water() -> void:
	for power_plant in power_plants:
		if not power_plant.done:
			return
	if(name == "Level3"):
		TransitionScene.transition_effect("res://scenes/menus_screens/after_final_level.tscn")
	else:
		TransitionScene.transition_effect("res://scenes/menus_screens/win_screen.tscn")

func _on_village_destroyed() -> void:
	TransitionScene.transition_effect("res://scenes/menus_screens/lose_screen.tscn")


func get_immovable_rects() -> Array:
	if $ImmovableZones == null:
		return []
	immovable_zones = $ImmovableZones.get_children()

	var rects = []
	for child in immovable_zones:
		var global_rect = child.get_global_rect()
		
		var pos = terrain_manager.mesh_generator.to_grid_pos(global_rect.position)
		var end = terrain_manager.mesh_generator.to_grid_pos(global_rect.end)
		
		rects.append([pos, end])
	return rects
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("save_level"):
		save_grid(terrain_manager.editor.grid)
	
func save_grid(grid):
	var text = ""

	for row in grid:
		for i in row.size():
			text += str(row[i])
			if i < row.size() - 1:
				text += ','
			else:
				text += ';'
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
		
func load_grid() -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	
	var grid = []
	for row in text.split(';', false):
		var gridRow = []
		for val in row.split(',', false):
			gridRow.append(float(val))
		grid.append(gridRow)
		
	return grid


# Called when the node is removed from the scene tree
func _exit_tree() -> void:
	AudioManager.stop_water_sound()  # Stop water music when exiting the level
	AudioManager.stop_gong_sound()
	

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
