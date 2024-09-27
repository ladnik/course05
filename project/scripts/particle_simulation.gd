extends Node2D

# import terrrain manager script to access the terrain data
#var TERRAIN_MANAGER = load("res://scripts/terrain_manager.gd")
var Constants = load('res://scripts/simulation_constants.gd')
var WATER_SOURCE = load('res://scripts/water_source.gd')
var water_source: Node2D

var fast_particle_array = PackedVector2Array()
var previous_positions = PackedVector2Array()
var velocities = PackedVector2Array() 
var force_array = PackedVector2Array()

var gravity_vector: Vector2 = Vector2(0, Constants.GRAVITY)
var mesh_generator: MeshInstance2D



# Called when the node enters the scene tree for the first time.

func _init():
	self.water_source = WATER_SOURCE.new(Vector2(100, 20), Vector2(0, 10), 10, 10, 0.2, 2, 0.0, 10.0)


func random_spawn():
	for i in range(Constants.NUMBER_PARTICLES):
		var position = Vector2(randf() * 50+100, randf() * 0)
		fast_particle_array.push_back(position)
		previous_positions.push_back(position)
		velocities.push_back(Vector2(0,0))
		force_array.push_back(Vector2(0,0))



func update(delta):
	self.water_source.spawn(delta, fast_particle_array, previous_positions, velocities, force_array)

	reset_forces()
	calculate_interaction_forces()
	integration_step(delta)
	double_density_relaxation(delta)
	check_oneway_coupling()
	calculate_next_velocity(delta)
	
	clipToBorder()

func integration_step(delta):
	for i in range(fast_particle_array.size()):
		var force: Vector2 = gravity_vector + force_array[i]
		#var force: Vector2 = gravity_vector 
		previous_positions[i] = fast_particle_array[i]
		velocities[i] += delta * force
		fast_particle_array[i] += delta * velocities[i]
	

	
func calculate_next_velocity(delta):
	for i in range(fast_particle_array.size()):
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

func collision_checker(i:int)-> Array:
	#print(fast_particle_array[i].x /2)
	#if fast_particle_array[i].y >fast_particle_array[i].x /2:
		#return true
	#else:
		#return false
	var array_collision = mesh_generator.continuous_collision(previous_positions[i], fast_particle_array[i])
	return array_collision
		
func check_oneway_coupling():
	for i in range(fast_particle_array.size()):
		var collision_object = collision_checker(i)
		if collision_object[0] == true:
			#print("True")
			#fast_particle_array[i]+=Vector2(2,-4).normalized()/Constants.SCALE/15
			fast_particle_array[i]+=collision_object[2].normalized()/Constants.SCALE
			
			

	
	
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
			velocities[i].x *= -1
		if fast_particle_array[i].x > Constants.WIDTH:
			fast_particle_array[i].x = Constants.WIDTH
			velocities[i].x *= -1
		if fast_particle_array[i].y < 0:
			fast_particle_array[i].y = 0
			velocities[i].y *= -1
		if fast_particle_array[i].y > Constants.HEIGHT:
			fast_particle_array[i].y = Constants.HEIGHT
			velocities[i].y = 0

func get_particle_positions():
	return fast_particle_array
