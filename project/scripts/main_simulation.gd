extends Node2D

@onready var mesh_generator: MeshInstance2D = $"../MeshGenerator"

var SIM = load('res://scripts/particle_simulation.gd').new()
var Constants = load('res://scripts/simulation_constants.gd')
var particle_mat = CanvasItemMaterial.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#View.size = Vector2(Constants.RENDER_WIDTH, Constants.RENDER_HEIGHT)
	#OS.window_size = $View.size
	SIM.mesh_generator = mesh_generator
	'''
	for p in SIM.fast_particle_array:
			var waterdraw = Sprite2D.new()
			waterdraw.add_to_group("water")
			waterdraw.texture = preload("res://assets/ball.png")
			waterdraw.scale *= Constants.PARTICLE_SIZE
			waterdraw.material = particle_mat
		
			waterdraw.position = p * Constants.SCALE
			add_child(waterdraw)
	'''



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	SIM.update(delta)
	#print(SIM.particles[1].position)
	'''
	var children = []
	for child in get_children():
			if child.is_in_group("water"):
				children.append(child)
				
	print(SIM.fast_particle_array.size())
	for p in range(SIM.fast_particle_array.size()):
		var draw_point = children[p]
		draw_point.position = (SIM.fast_particle_array[p] * Constants.SCALE)
	'''

	queue_redraw()
		
func _draw() -> void:
	# Draw a rectangle outline
	#draw_rect(Rect2(Vector2(0, 0), Vector2(Constants.RENDER_WIDTH, Constants.RENDER_HEIGHT)), Color(1, 1, 1), false)
	#draw_line(Vector2(0,0), Vector2(Constants.RENDER_WIDTH, Constants.RENDER_HEIGHT), Color(1, 1, 0))

	for p in range(SIM.fast_particle_array.size()):
		draw_circle(SIM.fast_particle_array[p] * Constants.SCALE, 5 * Constants.SCALE, Color(0, 1, 0), true)
		draw_circle(SIM.fast_particle_array[p] * Constants.SCALE, Constants.INTERACTION_RADIUS * Constants.SCALE, Color(0, 1, 0), false)
		# draw diagonal line from particle to interaction boundary
		draw_line(SIM.fast_particle_array[p] * Constants.SCALE, (SIM.fast_particle_array[p] + Vector2(1, 1).normalized() * Constants.INTERACTION_RADIUS) * Constants.SCALE, Color(1, 0, 0), 1, false)
		if Constants.DISPLAY_VELOCITY:
			draw_line(SIM.fast_particle_array[p] * Constants.SCALE, (SIM.fast_particle_array[p] + SIM.velocities[p]) * Constants.SCALE, Color(0, 1, 0), 1, false)
		if Constants.DISPLAY_FORCE:
			#print(SIM.particles[p].last_force)
			draw_line(SIM.fast_particle_array[p] * Constants.SCALE, (SIM.fast_particle_array[p] + SIM.force_array[p]) * Constants.SCALE, Color(0, 0, 1), 1, false)
