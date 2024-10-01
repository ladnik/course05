extends Node2D

class_name ParticleSimulation

@onready var mesh_generator: MeshInstance2D = $"../TerrainManager/MeshGenerator"

var SIM : Simulator
var Constants = load('res://scripts/simulation_constants.gd')
var particle_mat = CanvasItemMaterial.new()

func _init(pos_x, dis_x, pos_y, dis_y):
	#SIM = load('res://scripts/particle_simulation.gd').new(pos_x, dis_x, pos_y, dis_y)
	SIM = Simulator.new()
	SIM._init(50, 50, 500, 500)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#SIM.mesh_generator = mesh_generator

func _process(delta: float) -> void:
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	SIM.update(delta)

func _draw() -> void:

	# draw the particles
	const pCol = Color(0, 0, 1)
	for p in SIM.get_particle_positions():
		draw_circle(p , 5 , pCol, true)


	# draw the interaction radius etc for debugging
	if Constants.DEBUG:

		# draw the grid
		if Constants.USE_GRID:
			const gCol = Color(0, 0, 1)
			for x in range(0, Constants.WIDTH, Constants.GRID_SIZE):
				draw_line(Vector2(x, 0) , Vector2(x, Constants.HEIGHT) , gCol, 1, false)
			for y in range(0, Constants.HEIGHT, Constants.GRID_SIZE):
				draw_line(Vector2(0, y) , Vector2(Constants.WIDTH, y) , gCol, 1, false)


		const dCol = Color(1, 0, 0)
		var particle_positions = SIM.get_particle_positions()
		var velocities = []
		if Constants.DISPLAY_VELOCITY:
			velocities = SIM.get_particle_velocities()
		var forces = []
		if Constants.DISPLAY_FORCE:
			forces = SIM.get_particle_forces()
		for p in range(particle_positions.size()):
			var pos = particle_positions[p]
			draw_circle(pos , Constants.INTERACTION_RADIUS , pCol, false)
			
			# draw diagonal line from particle to interaction boundary
			draw_line(pos , (pos + Vector2(1, 1).normalized() * Constants.INTERACTION_RADIUS) , dCol, 1, false)

			if Constants.DISPLAY_VELOCITY:
				draw_line(pos , (pos + velocities[p]) , dCol, 1, false)
			
			if Constants.DISPLAY_FORCE:
				draw_line(pos , (pos + forces[p]) , dCol, 1, false)
