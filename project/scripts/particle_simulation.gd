extends RefCounted

# import terrrain manager script to access the terrain data
#const TERRAIN_MANAGER = preload("res://scripts/terrain_manager.gd")
var Constants = load('res://scripts/simulation_constants.gd')
var Particle = load('res://scripts/Particle.gd')

var fast_particle_array = PackedVector2Array()
var force_array = PackedVector2Array()

var particles : Array = []
var gravity_vector: Vector2 = Vector2(0, Constants.GRAVITY)


# Called when the node enters the scene tree for the first time.

func _init():
	# randomly spawn particles inside of HEIGHT and WIDTH
	for i in range(Constants.NUMBER_PARTICLES):
		var p = Particle.new()
		p.position = Vector2(randf() * Constants.WIDTH, randf() * Constants.HEIGHT)
		particles.append(p)
		fast_particle_array.push_back(p.position)
		force_array.push_back(Vector2(0,0))



func update(delta):
	#var m = OS.get_ticks_msec()
	
	#find_neighborhoods()
	#print('find_neighborhoods takes ' + str(OS.get_ticks_msec() - m) + ' ms.')
	#m = OS.get_ticks_msec()
	
	#calculate_density()
	#calculate_pressure()
	#calculate_force_density(draw_mode)
	reset_forces()
	calculate_interaction_forces()
	integration_step(delta)
	clipToBorder()
	#collision_handling()
	
	#breakpoint
	#grid.update_structure(particles)
	
	#print('everything else takes ' + str(OS.get_ticks_msec() - m) + ' ms.')
	#m = OS.get_ticks_msec()



func integration_step(delta):
	for i in range(Constants.NUMBER_PARTICLES):
		var force: Vector2 = gravity_vector + force_array[i]
		particles[i].velocity += delta * force
		particles[i].position += delta * particles[i].velocity
		fast_particle_array[i] = particles[i].position
		particles[i].last_force = particles[i].force
		particles[i].force = Vector2(0,0)
		

func collsison_reflection(normal_vector: Vector2):
	pass
	

func interaction_force(position1, position2) -> Vector2:
	var r = position2 - position1
	if r.length() > 2 * Constants.INTERACTION_RADIUS:
		return Vector2(0,0)
	
	var overlap = 2 * Constants.INTERACTION_RADIUS * r.normalized() - r
	
	var force = Constants.SPRING_CONSTANT * Vector2(overlap.x, overlap.y + 2 * Constants.INTERACTION_RADIUS)
	return force
	
func calculate_interaction_forces() -> void:
	# sum over all particles without double counting
	for i in range(fast_particle_array.size()):
		for j in range(i+1, fast_particle_array.size()):
			var force = interaction_force(fast_particle_array[i], fast_particle_array[j])
			force_array[i] -= force
			force_array[j] += force

func reset_forces():
	for i in range(particles.size()):
		force_array[i] = Vector2(0,0)

func clipToBorder():
	for i in range(particles.size()):
		if particles[i].position.x < 0:
			particles[i].position.x = 0
			particles[i].velocity.x = 0
		if particles[i].position.x > Constants.WIDTH:
			particles[i].position.x = Constants.WIDTH
			particles[i].velocity.x = 0
		if particles[i].position.y < 0:
			particles[i].position.y = 0
			particles[i].velocity.y = 0
		if particles[i].position.y > Constants.HEIGHT:
			particles[i].position.y = Constants.HEIGHT
			particles[i].velocity.y = 0
