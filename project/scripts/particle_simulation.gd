extends RefCounted

# import terrrain manager script to access the terrain data
#var TERRAIN_MANAGER = load("res://scripts/terrain_manager.gd")
var Constants = load('res://scripts/simulation_constants.gd')
var Particle = load('res://scripts/Particle.gd')



var particles : Array = []
var gravity_vector: Vector2 = Vector2(0, Constants.GRAVITY)



# Called when the node enters the scene tree for the first time.

func _init():
	# randomly spawn particles inside of HEIGHT and WIDTH
	for i in range(Constants.NUMBER_PARTICLES):
		var p = Particle.new()
		p.position = Vector2(randf() * Constants.WIDTH, randf() * Constants.HEIGHT)
		particles.append(p)



func update(delta):
	#var m = OS.get_ticks_msec()
	
	#find_neighborhoods()
	#print('find_neighborhoods takes ' + str(OS.get_ticks_msec() - m) + ' ms.')
	#m = OS.get_ticks_msec()
	
	#calculate_density()
	#calculate_pressure()
	#calculate_force_density(draw_mode)
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
		particles[i].pre_position = particles[i].position
		particles[i].force = gravity_vector + particles[i].force
		particles[i].velocity += delta * particles[i].force
		particles[i].position += delta * particles[i].velocity
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
	

func interaction_force(particle1, particle2) -> Vector2:
	var distance = particle1.position.distance_to(particle2.position)
	if distance > Constants.INTERACTION_RADIUS:
		return Vector2(0,0)
	
	var force = Vector2(0,0)
	
	var overlap = 2 * Constants.INTERACTION_RADIUS - distance
	var normal = (particle1.position - particle2.position).normalized()
	
	force = Constants.SPRING_CONSTANT * overlap * normal
	
	return force

	
func calculate_interaction_forces() -> void:
	# sum over all particles without double counting
	for i in range(particles.size()):
		for j in range(i+1, particles.size()):
			var force = interaction_force(particles[i], particles[j])
			particles[i].force += force
			particles[j].force -= force

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
