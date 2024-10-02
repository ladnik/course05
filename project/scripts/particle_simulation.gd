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

	for key in grid.keys():
		density_grid[key] = grid[key].size()

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

func respawn_particle(particle_index: int, pos: Vector2, vel: Vector2, scale_area: float)-> void:
	var spawnPosition = Vector2(randf()*scale_area+pos.x,randf()*scale_area+pos.y)
	current_positions[particle_index]= spawnPosition
	previous_positions[particle_index]= spawnPosition
	velocities[particle_index]= vel
	forces[particle_index]= Vector2(0,0)
	particle_valid[particle_index]= true

func respawn_particle_at_source(particle_index: int)->void:
	var pos = Vector2(200,200)
	var vel = Vector2(0,0)
	var distribution = 50
	respawn_particle(particle_index,pos,vel,distribution)

func update(delta) -> void:
	if Constants.NUMBER_PARTICLES < 0:
		self.water_source.spawn(delta, current_positions, previous_positions, velocities, forces, particle_valid)

	# gravity
	integration_step(delta)

	# spring forces
	# reset_forces()
	# calculate_interaction_forces
	
	# double density relaxation
	double_density_relaxation(delta)
	calculate_next_velocity(delta)

	# terrain/boundary conditions
	bounceFromBorder()
	check_oneway_coupling()
	
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
		if velocity.y < -200:
			velocity.y = -200

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
	return mesh_generator.continuous_collision(previous_positions[i], current_positions[i])


func check_oneway_coupling() -> void:
	for i in range(current_positions.size()):
		var collision_object = collision_checker(i)
		if collision_object[0] == true:
			#set posiion to boundary
			current_positions[i] += collision_object[2].normalized() *5
			#new velocity
			velocities[i]= velocities[i]-1*velocities[i].dot(collision_object[2].normalized())*collision_object[2].normalized()
			if collision_checker(i)[0]:
				#respawn particle if it collision fails
				respawn_particle_at_source(i)

func get_all_neighbour_particles(grid_pos: Vector2):
	var neighbour_particles = grid[grid_pos]
	for neighbour in get_grid_neighbours(grid_pos):
		if grid.has(neighbour):
			neighbour_particles += grid[neighbour]

	return neighbour_particles


func double_density_relaxation(delta) -> void:
	build_grid()

	for cell_key in grid.keys():
		for i in grid[cell_key]:
			var density = 0
			var density_near = 0

			var neighbors = get_all_neighbour_particles(cell_key)

			for j in neighbors:
				if i==j:
					continue
				var rij = current_positions[j] - current_positions[i]
				var q=rij.length()/Constants.INTERACTION_RADIUS
				if q < 1:
					density+=(1-q)**2
					density_near+=(1-q)**3
			#compute Pressure
			var pressure= Constants.K*(density-Constants.DENSITY_ZERO)
			var pressure_near= Constants.KNEAR*density_near
			var pos_displacement_A = Vector2(0,0)

			for j in neighbors:
				if i==j:
					continue
				var rij = current_positions[j] - current_positions[i]
				var q=rij.length()/Constants.INTERACTION_RADIUS
				if q < 1:
					rij=rij.normalized()
					var displacement_term:Vector2 =delta**2 * (pressure*(1-q)+pressure_near*(1-q))*rij
					current_positions[j] += displacement_term/2
					pos_displacement_A -= displacement_term/2
			current_positions[i] += pos_displacement_A


func bounceFromBorder() -> void:
	for i in range(current_positions.size()):
		if current_positions[i].x  < 0:
			respawn_particle_at_source(i)
		if current_positions[i].x > Constants.WIDTH:
			respawn_particle_at_source(i)
		if current_positions[i].y> Constants.HEIGHT:
			respawn_particle_at_source(i)

func get_particle_positions():
	var particles = PackedVector2Array()
	for i in range(current_positions.size()):
		if particle_valid[i]:
			particles.push_back(current_positions[i])

	return particles

# delete particle at the translated index from the valid particle list
func delete_particle(index: int) -> void:
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
