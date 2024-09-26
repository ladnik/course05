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
	
		
		waterdraw.position = p.position
		print(p.position)
		add_child(waterdraw)
		# Get all children of the current node
		var children = get_children()

		for child in children:
			print(child.name)
	


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
		draw_point.position = i_reset*(SIM.particles[p].position)
		#print(draw_point)
		
