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
	initialize(pos_x, dis_x, pos_y, dis_y)

func generate_level():
	terrain_manager.generate_terrain(seed, type, octaves, frequency, get_immovable_rects())
	initialize(pos_x, dis_x, pos_y, dis_y)
		

func initialize(pos_x, dis_x, pos_y, dis_y): 
	var particle_simulation = ParticleSimulation.new(pos_x, dis_x, pos_y, dis_y)
	self.add_child(particle_simulation)
	
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
