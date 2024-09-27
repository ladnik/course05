extends RefCounted

# import terrrain manager script to access the terrain data
#var TERRAIN_MANAGER = load("res://scripts/terrain_manager.gd")
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
	calculate_next_velocity(delta)
	
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
	

	
func calculate_next_velocity(delta):
	for i in range(Constants.NUMBER_PARTICLES):
		#Calculate the new velocity from the previous and current position
		var velocity : Vector2 = (particles[i].position - particles[i].pre_position)/delta
		particles[i].velocity = velocity
		print(velocity)
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

#func collision_checker(boundary, pos):
	#pass
#func check_oneway_coupling():
	#for i in range(particles.size()):
		#var collision_object = collision_checker(particles[i].pre_position,particles[i].position)
		#if collision_object.bool == True:
			#handle_oneway_coupling(i:int,collision_object.normalvector, collision_object.intersection)
#func handle_oneway_coupling(particle ,normal_vector:Vector2,new_position:Vector2):
	#particles[i].position=new_position
	#var v_x = particles[i].velocity.x
	#var v_y = particles[i].velocity.y
	#var n_x = normal_vector.x
	#var n_y = normal_vector.y
	##R=V−2⋅(V⋅N)⋅N
	#particles[i].velocity = particles[i].velocity- 2*(v_x*n_x+v_y*n_y)*normal_vector
	

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
