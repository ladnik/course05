extends Node2D

@onready var mesh_generator: MeshInstance2D = $"../MeshGenerator"

var SIM = load('res://scripts/particle_simulation.gd').new()
var Constants = load('res://scripts/simulation_constants.gd')
var particle_mat = CanvasItemMaterial.new()

var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SIM.mesh_generator = mesh_generator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	SIM.update(delta)

	queue_redraw()
	time += delta
	if time > 1.0:
		time = 0.0
		for i in range(0, 100):
			SIM.delete_particle(i)


func _draw() -> void:

	# draw the particles
	const pCol = Color(0, 0, 1)
	for p in SIM.get_particle_positions():
		draw_circle(p , 5 , pCol, true)


	# draw the interaction radius etc for debugging
	if Constants.DEBUG:

		# draw the grid
		if Constants.GRIDSEARCH:
			const gCol = Color(0, 0, 1)
			for x in range(0, Constants.WIDTH, Constants.GRID_SIZE):
				draw_line(Vector2(x, 0) , Vector2(x, Constants.HEIGHT) , gCol, 1, false)
			for y in range(0, Constants.HEIGHT, Constants.GRID_SIZE):
				draw_line(Vector2(0, y) , Vector2(Constants.WIDTH, y) , gCol, 1, false)


		const dCol = Color(1, 0, 0)
		var particle_positions = SIM.get_particle_positions()
		var velocities = []
		if Constants.DISPLAY_VELOCITY:
			velocities = SIM.get_velocities()
		var forces = []
		if Constants.DISPLAY_FORCE:
			forces = SIM.get_forces()
		for p in range(particle_positions.size()):
			var pos = particle_positions[p]
			draw_circle(pos , Constants.INTERACTION_RADIUS , pCol, false)
			
			# draw diagonal line from particle to interaction boundary
			draw_line(pos , (pos + Vector2(1, 1).normalized() * Constants.INTERACTION_RADIUS) , dCol, 1, false)

			if Constants.DISPLAY_VELOCITY:
				draw_line(pos , (pos + velocities[p]) , dCol, 1, false)
			
			if Constants.DISPLAY_FORCE:
				draw_line(pos , (pos + forces[p]) , dCol, 1, false)
