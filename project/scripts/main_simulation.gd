extends Node2D

@onready var mesh_generator: MeshInstance2D = $"../MeshGenerator"

var SIM = load('res://scripts/particle_simulation.gd').new()
var Constants = load('res://scripts/simulation_constants.gd')
var particle_mat = CanvasItemMaterial.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SIM.mesh_generator = mesh_generator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	SIM.update(delta)

	queue_redraw()


func _draw() -> void:

	# draw the particles
	const pCol = Color(0, 0, 1)
	for p in range(SIM.current_positions.size()):
		draw_circle(SIM.current_positions[p] , 5 , pCol, true)


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
		for p in range(SIM.current_positions.size()):
			var pos = SIM.current_positions[p]
			draw_circle(pos , Constants.INTERACTION_RADIUS , pCol, false)
			
			# draw diagonal line from particle to interaction boundary
			draw_line(pos , (pos + Vector2(1, 1).normalized() * Constants.INTERACTION_RADIUS) , dCol, 1, false)

			if Constants.DISPLAY_VELOCITY:
				draw_line(pos , (pos + SIM.velocities[p]) , dCol, 1, false)
			
			if Constants.DISPLAY_FORCE:
				draw_line(pos , (pos + SIM.forces[p]) , dCol, 1, false)
