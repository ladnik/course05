extends Node2D

var SIM = load('res://scripts/particle_simulation.gd').new()
var Constants = load('res://scripts/simulation_constants.gd')
var particle_mat = CanvasItemMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#View.size = Vector2(Constants.RENDER_WIDTH, Constants.RENDER_HEIGHT)
	#OS.window_size = $View.size
	for p in SIM.particles:
			var waterdraw = Sprite2D.new()
			waterdraw.texture = preload("res://assets/ball.png")
			waterdraw.material = particle_mat
		
			waterdraw.position = p.position * Constants.SCALE
			add_child(waterdraw)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	SIM.update(delta)
	#print(SIM.particles[1].position)
	var children = []
	for child in get_children():
			if child is Sprite2D:
				children.append(child)
				
	for p in range(SIM.particles.size()):
		var draw_point = get_child(p+1)
		var i_reset=1
		draw_point.position = i_reset*(SIM.particles[p].position * Constants.SCALE)

	queue_redraw()
		
func _draw() -> void:
	# Draw a rectangle outline
	draw_rect(Rect2(Vector2(0, 0), Vector2(Constants.RENDER_WIDTH, Constants.RENDER_HEIGHT)), Color(1, 1, 1), false)
	for p in range(SIM.particles.size()):
		draw_circle(SIM.particles[p].position * Constants.SCALE, Constants.INTERACTION_RADIUS * Constants.SCALE, Color(1, 0, 0), false)
		# draw diagonal line from particle to interaction boundary
		draw_line(SIM.particles[p].position * Constants.SCALE, (SIM.particles[p].position + Vector2(1, 1).normalized() * Constants.INTERACTION_RADIUS) * Constants.SCALE, Color(1, 0, 0), 1, false)
		if Constants.DISPLAY_VELOCITY:
			draw_line(SIM.particles[p].position * Constants.SCALE, (SIM.particles[p].position + SIM.particles[p].velocity) * Constants.SCALE, Color(0, 1, 0), 1, false)
		if Constants.DISPLAY_FORCE:
			#print(SIM.particles[p].last_force)
			draw_line(SIM.fast_particle_array[p] * Constants.SCALE, (SIM.fast_particle_array[p] + SIM.force_array[p]) * Constants.SCALE, Color(0, 0, 1), 1, false)
