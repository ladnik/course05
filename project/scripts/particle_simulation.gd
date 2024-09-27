extends RefCounted

# import terrrain manager script to access the terrain data
#var TERRAIN_MANAGER = load("res://scripts/terrain_manager.gd")
var Constants = load('res://scripts/simulation_constants.gd')

var fast_particle_array = PackedVector2Array()
var previous_positions = PackedVector2Array()
var velocities = PackedVector2Array() 
var force_array = PackedVector2Array()

var gravity_vector: Vector2 = Vector2(0, Constants.GRAVITY)



# Called when the node enters the scene tree for the first time.

func _init():
	# randomly spawn particles inside of HEIGHT and WIDTH
	for i in range(Constants.NUMBER_PARTICLES):
		var position = Vector2(randf() * 50+100, randf() * 50+100)
		fast_particle_array.push_back(position)
		previous_positions.push_back(position)
		velocities.push_back(Vector2(0,0))
		force_array.push_back(Vector2(0,0))



func update(delta):
	reset_forces()
	calculate_interaction_forces()
	integration_step(delta)
	double_density_relaxation(delta)
	calculate_next_velocity(delta)
	
	clipToBorder()

func integration_step(delta):
	for i in range(Constants.NUMBER_PARTICLES):
		var force: Vector2 = gravity_vector + force_array[i]
		#var force: Vector2 = gravity_vector 
		previous_positions[i] = fast_particle_array[i]
		velocities[i] += delta * force
		fast_particle_array[i] += delta * velocities[i]
	

	
func calculate_next_velocity(delta):
	for i in range(Constants.NUMBER_PARTICLES):
		#Calculate the new velocity from the previous and current position
		var velocity : Vector2 = (fast_particle_array[i] - previous_positions[i]) / delta
		velocities[i] = velocity

func interaction_force(position1, position2) -> Vector2:
	var r = position2 - position1
	if r.length() > 2 * Constants.INTERACTION_RADIUS:
		return Vector2(0,0)
	
	var overlap = 2 * Constants.INTERACTION_RADIUS * r.normalized() - r
	
	var force = Constants.SPRING_CONSTANT * Vector2(min(overlap.x, 0.2* Constants.INTERACTION_RADIUS), min(overlap.y,0.05*Constants.INTERACTION_RADIUS) + 2 * Constants.INTERACTION_RADIUS)
	
	return force
	
func calculate_interaction_forces() -> void:
	# sum over all particles without double counting
	for i in range(fast_particle_array.size()):
		for j in range(i+1, fast_particle_array.size()):
			var force = interaction_force(fast_particle_array[i], fast_particle_array[j])
			force_array[i] -= force
			force_array[j] += force

func reset_forces():
	for i in range(fast_particle_array.size()):
		force_array[i] = Vector2(0,0)

#func collision_checker(boundary, pos):
	#pass
#func check_oneway_coupling():
	#for i in range(particles.size()):
		#var collision_object = collision_checker(particles[i].pre_position,fast_particle_array[i])
		#if collision_object.bool == True:
			#handle_oneway_coupling(i:int,collision_object.normalvector, collision_object.intersection)
			
#func handle_oneway_coupling(particle ,normal_vector:Vector2,new_position:Vector2):
	#fast_particle_array[i]=new_position
	#var v_x = velocities[i].x
	#var v_y = velocities[i].y
	#var n_x = normal_vector.x
	#var n_y = normal_vector.y
	##R=V−2⋅(V⋅N)⋅N
	#particles[i].velocity = particles[i].velocity- 2*(v_x*n_x+v_y*n_y)*normal_vector
	
func double_density_relaxation(delta):
	for i in range(fast_particle_array.size()):
		var desnity = 0
		var density_near = 0
		var particleA= fast_particle_array[i]
		var h = 15 #cut-off radius
		var k = 0.1 
		var k_near= 0.2
		var density_zero= 10
		for j in range(fast_particle_array.size()):
			if i==j:
				continue
			var particleB=fast_particle_array[j]
			var rij = particleB-particleA
			var q=rij.length()/h
			if q < 1:
				desnity+=(1-q)**2
				density_near+=(1-q)**3
		#compute Pressure
		var pressure= k*(desnity-density_zero)
		var pressure_near= k_near*density_near
		var pos_displacement_A = Vector2(0,0)
		for j in range(fast_particle_array.size()):
			if i==j:
				continue
			var particleB=fast_particle_array[j]
			var rij = particleB-particleA
			var q=rij.length()/h
			if q < 1:
				rij=rij.normalized()
				var displacement_term:Vector2 =delta**2 * (pressure*(1-q)+pressure_near*(1-q)**2)*rij
				fast_particle_array[j] += displacement_term/2
				pos_displacement_A -= displacement_term/2
		fast_particle_array[i] += pos_displacement_A
				
		
			
			
func clipToBorder():
	for i in range(fast_particle_array.size()):
		if fast_particle_array[i].x < 0:
			fast_particle_array[i].x = 0
			velocities[i].x = 0
		if fast_particle_array[i].x > Constants.WIDTH:
			fast_particle_array[i].x = Constants.WIDTH
			velocities[i].x = 0
		if fast_particle_array[i].y < 0:
			fast_particle_array[i].y = 0
			velocities[i].y = 0
		if fast_particle_array[i].y > Constants.HEIGHT:
			fast_particle_array[i].y = Constants.HEIGHT
			velocities[i].y = 0

func get_particle_positions():
	return fast_particle_array
