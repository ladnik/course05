extends Node2D

# import terrrain manager script to access the terrain data
#var TERRAIN_MANAGER = load("res://scripts/terrain_manager.gd")
var Constants = load('res://scripts/simulation_constants.gd')
var WATER_SOURCE = load('res://scripts/water_source.gd')
var water_source: Node2D

var current_positions: PackedVector2Array = PackedVector2Array()
var previous_positions: PackedVector2Array = PackedVector2Array()
var velocities: PackedVector2Array = PackedVector2Array() 
var forces: PackedVector2Array = PackedVector2Array()
var particle_valid: Array = Array()

var gravity_vector: Vector2 = Vector2(0, Constants.GRAVITY)
var mesh_generator: MeshInstance2D

var grid: Dictionary = {}
var density_grid: Dictionary = {}

var neighborsToCheck: Array = [Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)]


# Called when the node enters the scene tree for the first time.
func _init(pos_x, dis_x, pos_y, dis_y):
	if Constants.NUMBER_PARTICLES < 0:
		self.water_source = WATER_SOURCE.new(Vector2(pos_x, pos_y), Vector2(0, 10), 10, 10, 0.2, 2, 0.0, 4.0)
	else:
		random_spawn(pos_x, dis_x, pos_y, dis_y)

# Convert world position to grid position
func world_to_grid(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / Constants.GRID_SIZE), floor(pos.y / Constants.GRID_SIZE))

# Build grid based on particle positions
func build_grid() -> void:
	grid.clear()

	for i in range(current_positions.size()):
		var grid_pos = world_to_grid(current_positions[i])

		if grid.has(grid_pos):
			grid[grid_pos].append(i)
		else:
			grid[grid_pos] = [i]

func get_grid_neighbours(grid_pos:Vector2) -> Array: 
	var neigbour_cells: Array =[] 
	for i in range(-1,2):
		for j in range(-1,2):
			if i==0 and j==0:
				continue
			else:
				neigbour_cells.append(grid_pos+Vector2(i,j))
	return neigbour_cells
	
func random_spawn(pos_x, dis_x, pos_y, dis_y) -> void:
	for i in range(Constants.NUMBER_PARTICLES):
		var spawnPosition = Vector2(randf() * dis_x + pos_x, randf() * dis_y + pos_y)
		current_positions.push_back(spawnPosition)
		previous_positions.push_back(spawnPosition)
		velocities.push_back(Vector2(0,0))
		forces.push_back(Vector2(0,0))
		particle_valid.push_back(true)


func update(delta) -> void:
	if Constants.NUMBER_PARTICLES < 0:
		self.water_source.spawn(delta, current_positions, previous_positions, velocities, forces, particle_valid)

	# reset everything
	reset_forces()
	
	# calculate the next step
	calculate_interaction_forces()
	integration_step(delta)
	
	#double_density_relaxation(delta)
	calculate_next_velocity(delta)
	check_oneway_coupling()

	bounceFromBorder()

func integration_step(delta) -> void:
	for i in range(current_positions.size()):
		var force: Vector2 = gravity_vector + forces[i]
		#var force: Vector2 = gravity_vector 
		previous_positions[i] = current_positions[i]
		velocities[i] += delta * force
		current_positions[i] += delta * velocities[i]
	

	
func calculate_next_velocity(delta) -> void:
	for i in range(current_positions.size()):
		#Calculate the new velocity from the previous and current position
		var velocity : Vector2 = (current_positions[i] - previous_positions[i]) / delta
		velocities[i] = velocity

func interaction_force(position1, position2) -> Vector2:
	var r = position2 - position1
	if r.length() > 2 * Constants.INTERACTION_RADIUS:
		return Vector2(0,0)
	
	var overlap = 2 * Constants.INTERACTION_RADIUS * r.normalized() - r
	
	var forceX = overlap.x
	var forceY = overlap.y

	var force = Constants.SPRING_CONSTANT * Vector2(forceX, forceY)
	
	return force
	
func calculate_interaction_forces() -> void:
	# sum over all particles without double counting
	if not Constants.USE_GRID:
		for i in range(current_positions.size()):
			for j in range(i + 1, current_positions.size()):
				apply_force(i, j)
	else:

		build_grid()

		for cell_key in grid.keys():
			var cell = grid[cell_key]

			# apply forces within the cell
			for i in range(cell.size()):
				for j in range(0, cell.size()):
					apply_force(cell[i], cell[j])
			
			# apply forces to neighbouring cells
			for neighbour_cell_key in get_grid_neighbours(cell_key):
				
				if grid.has(neighbour_cell_key):
					var neighbour_cell = grid[neighbour_cell_key]
					for i in range(cell.size()):
						for j in range(neighbour_cell.size()):
							apply_force(cell[i], neighbour_cell[j])

func apply_force(index1: int, index2: int) -> void:
	var force = interaction_force(current_positions[index1], current_positions[index2])
	forces[index1] -= force
	forces[index2] += force

func reset_forces():
	for i in range(current_positions.size()):
		forces[i] = Vector2(0,0)

func collision_checker(i:int)-> Array:
	#print(current_positions[i].x /2)
	#if current_positions[i].y >current_positions[i].x /2:
		#return true
	#else:
		#return false
	var array_collision = mesh_generator.continuous_collision(previous_positions[i], current_positions[i])
	return array_collision

func check_oneway_coupling() -> void:
	for i in range(current_positions.size()):
		var collision_object = collision_checker(i)
		var penetration_depth = (current_positions[i]-collision_object[1]).dot(collision_object[2].normalized())
		if collision_object[0] == true:
			#set posiion to boundary
			current_positions[i] += collision_object[2].normalized() * 0.5
			#new velocity
			velocities[i]= velocities[i]-1*velocities[i].dot(collision_object[2].normalized())*collision_object[2].normalized()
			if collision_checker(i)[0]:
				#respawn particle if it collision fails
				var spawnPosition = Vector2(randf() * 50 + 600, randf() * 50 + 200)
				current_positions[i]= spawnPosition
				previous_positions[i]= spawnPosition

func double_density_relaxation_cells(delta):
	pass

func double_density_relaxation(delta) -> void:
	for i in range(current_positions.size()):
		var density = 0
		var density_near = 0
		var particleA= current_positions[i]
		var h = 30 #cut-off radius
		var k = 0.1 
		var k_near= 0.2
		var density_zero= 10
		for j in range(current_positions.size()) :
			if i==j:
				continue
			var particleB=current_positions[j]
			var rij = particleB-particleA
			var q=rij.length()/h
			if q < 1:
				density+=(1-q)**2
				density_near+=(1-q)**3
		#compute Pressure
		var pressure= k*(density-density_zero)
		var pressure_near= k_near*density_near
		var pos_displacement_A = Vector2(0,0)
		for j in range(current_positions.size()):
			if i==j:
				continue
			var particleB=current_positions[j]
			var rij = particleB-particleA
			var q=rij.length()/h
			if q < 1:
				rij=rij.normalized()
				var displacement_term:Vector2 =delta**2 * (pressure*(1-q)+pressure_near*(1-q)**2)*rij
				current_positions[j] += displacement_term/2
				pos_displacement_A -= displacement_term/2
		current_positions[i] += pos_displacement_A


func bounceFromBorder() -> void:
	for i in range(current_positions.size()):
		if current_positions[i].x - Constants.INTERACTION_RADIUS < 0:
			current_positions[i].x = Constants.INTERACTION_RADIUS
			velocities[i].x *= -0.5
		if current_positions[i].x + Constants.INTERACTION_RADIUS > Constants.WIDTH:
			current_positions[i].x = Constants.WIDTH - Constants.INTERACTION_RADIUS
			velocities[i].x *= -0.5
		if current_positions[i].y +  Constants.INTERACTION_RADIUS > Constants.HEIGHT:
			current_positions[i].y = Constants.HEIGHT - Constants.INTERACTION_RADIUS
			velocities[i].y *= -0.5

func get_particle_positions():
	var particles = PackedVector2Array()
	for i in range(current_positions.size()):
		if particle_valid[i]:
			particles.push_back(current_positions[i])

	return particles

func delete_particle(index: int) -> void:
	# input is index in array of valid particle positions. Need to find the index in the array of all particles and set the particle to invalid
	var valid_index = 0
	for i in range(current_positions.size()):
		if particle_valid[i]:
			if valid_index == index:
				particle_valid[i] = false
				return
			valid_index += 1

#### ONLY USED FOR DEBUGGING ####
func get_velocities():
	var valid_velocities = PackedVector2Array()
	for i in range(current_positions.size()):
		if particle_valid[i]:
			valid_velocities.push_back(velocities[i])

	return valid_velocities

func get_forces():
	var valid_forces = PackedVector2Array()
	for i in range(current_positions.size()):
		if particle_valid[i]:
			valid_forces.push_back(forces[i])

	return valid_forces
