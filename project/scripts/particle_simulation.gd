extends RefCounted

# import terrrain manager script to access the terrain data
#const TERRAIN_MANAGER = preload("res://scripts/terrain_manager.gd")
var Constants = load('res://scripts/simulation_constants.gd')
var Particle = load('res://scripts/Particle.gd')



var particles : Array = []
var gravity_vector: Vector2 = Vector2(0, Constants.GRAVITY)


# Called when the node enters the scene tree for the first time.

func _init():
	
	for i in range(Constants.NUMBER_PARTICLES):
		var pos: Vector2 = Vector2(200+i*20,0)
		var vel: Vector2= Vector2(0,10)
		
		particles.append(Particle.new(pos,vel))



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
	#collision_handling()
	
	#breakpoint
	#grid.update_structure(particles)
	
	#print('everything else takes ' + str(OS.get_ticks_msec() - m) + ' ms.')
	#m = OS.get_ticks_msec()



func integration_step(delta):
	for i in range(Constants.NUMBER_PARTICLES):
		particles[i].velocity += delta * gravity_vector
		particles[i].velocity += delta * particles[i].force
		particles[i].position += delta * particles[i].velocity
		particles[i].force = Vector2(0,0)
		

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
