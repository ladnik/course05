extends Node2D

const TILE_SIZE = 16  # Specify the tile side length here

var _width = 400
var _height = 100

var grid : Array = []
var tiles = []
var gridNoise = FastNoiseLite.new()

# Basic functions

var kernel_radius = 5
func cubic_spline_kernel(x_origin: Vector2, x: Vector2) -> float:
	var distance = x_origin.distance_to(x)
	var q = distance / kernel_radius
	
	if q > 1.0:
		return 0.0
	
	var sigma = 10.0 / (7.0 * PI * kernel_radius * kernel_radius)
	var kernel_value: float
	
	if q <= 0.5:
		kernel_value = 6.0 * (q * q * q - q * q) + 1.0
	else:
		kernel_value = 2.0 * pow(1.0 - q, 3)
	
	return sigma * kernel_value


func on_grid(grid_pos):
	return 0 <= grid_pos.x and grid_pos.x < len(grid[0]) and 0 <= grid_pos.y and grid_pos.y < len(grid)

func to_grid_pos(pixel_pos):
	var pixel_x = pixel_pos[0]
	var pixel_y = pixel_pos[1]
	
	var grid_x = pixel_x / TILE_SIZE
	var grid_y = pixel_y / TILE_SIZE
	
	return Vector2(grid_x, grid_y)


# Logic functions

func apply_kernel(grid_pos, target_value):
	var kernel_multiplier = 100
	
	for i in range(-kernel_radius - 1, kernel_radius + 1):
		for j in range(-kernel_radius - 1, kernel_radius + 1):
			var grid_pos_kernel = Vector2(grid_pos.x + j, grid_pos.y + i)
			
			if on_grid(grid_pos_kernel):
				var kernel_value = kernel_multiplier * cubic_spline_kernel(grid_pos, grid_pos_kernel)
				#var kernel_value = 1
				kernel_value = min(1.0, max(0, kernel_value))
				
				var new_grid_value = (1 - kernel_value) * grid[grid_pos_kernel.y][grid_pos_kernel.x] + kernel_value * target_value
				
				grid[grid_pos_kernel.y][grid_pos_kernel.x] = min(1.0, max(0, new_grid_value))

func update_colors():
	for y in range(_height):
		for x in range(_width):
			tiles[y][x].color = Color(grid[y][x], grid[y][x], grid[y][x])


func generateGrid():
	var returnBoundaries : Array[PackedVector2Array] = [] # all boundaries
	var boundary : PackedVector2Array = [] # current boundary

	# Generate grid array
	for y in range(_height):
		var grid_row = []
		for x in range(_width):
			grid_row.append(0)
		grid.append(grid_row)

	# Initialize noise generator
	gridNoise.seed = 0815;
	gridNoise.noise_type = FastNoiseLite.TYPE_PERLIN
	gridNoise.fractal_octaves = 4
	gridNoise.frequency = 0.0075

	# Fill grid with noise data and generate output boundaries
	for x in range(_width):
		var maxHeight = round(gridNoise.get_noise_1d(x) * _height * 2 + _height / 2.5)

		boundary.append(Vector2(x, maxHeight))

		print(maxHeight)
		for y in range(_height):
			if maxHeight <= y:
				grid[y][x] = 1

	# Genereate the two bottom points
	boundary.append(Vector2(_width - 1, _height - 1))
	boundary.append(Vector2(0, 		   _height - 1))

	returnBoundaries.append(boundary)
	
	for y in range(80, 90):
		for x in range(100, 150):
			grid[y][x] = 0


	for y in range(_height):
		var maxHeight = round((sin(y / 3.0) * 10.0 + 70.0) )
		print("maxHeight")
		print(maxHeight)
		for x in range(0, maxHeight):
			grid[y][x] = 0

	return returnBoundaries

func findBoundaries(): 
	var outerPoints = grid.duplicate(true)
	for y in range(1, _height - 1):
		for x in range(1, _width - 1):
			if grid[y][x] == 1:
				var neighbors = grid[y - 1][x] + grid[y + 1][x] + grid[y][x + 1] + grid[y][x - 1]

				if neighbors < 4:
					outerPoints[y][x] = 2
				if neighbors > 4:
					print("error")
					print(x)
					print(y)
					print(neighbors)
					print(grid[y - 1][x])
					print(grid[y + 1][x])
	return outerPoints


func renderGrid(): 
	var outerPoints = findBoundaries()

	for y in range(_height):
		for x in range(_width):
			var tile = ColorRect.new()
			tile.size = Vector2(TILE_SIZE, TILE_SIZE)
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			if outerPoints[y][x] == 2:
				tile.color = Color.RED  
			elif outerPoints[y][x] == 1:
				tile.color = Color.GRAY  
			else:
				tile.color = Color.SKY_BLUE
			add_child(tile)

func draw_grid_lines():
	var width = _width * TILE_SIZE
	var height = _height * TILE_SIZE
	
	# Draw vertical lines
	for x in range(_width + 1):
		var start = Vector2(x * TILE_SIZE, 0)
		var end = Vector2(x * TILE_SIZE, height)
		draw_line(start, end, Color.WEB_GRAY, 1.0)
	
	# Draw horizontal lines
	for y in range(_height + 1):
		var start = Vector2(0, y * TILE_SIZE)
		var end = Vector2(width, y * TILE_SIZE)
		draw_line(start, end, Color.WEB_GRAY, 1.0)

# Godot functions

func _ready():
	generateGrid()

	# Display the grid
	for y in range(_height):
		
		var tile_row = []
		
		for x in range(_width):
			var tile = ColorRect.new()
			tile.size = Vector2(TILE_SIZE, TILE_SIZE)
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			tile_row.append(tile)
			tile.z_index = -1
			
			add_child(tile)
			
		tiles.append(tile_row)
		
	update_colors()

	#renderGrid()
			
func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	
	var mouse_pos_grid = to_grid_pos(mouse_pos)
	
	var x_idx = int(mouse_pos_grid.x)
	var y_idx = int(mouse_pos_grid.y)
	
	# place new terrain
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and on_grid(mouse_pos_grid):
		
		apply_kernel(mouse_pos_grid, 1.0)
		
		grid[y_idx][x_idx] = 1.0
				
		update_colors()
		draw_grid_lines()
		
		
	# remove terrain
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and on_grid(mouse_pos_grid):
		grid[y_idx][x_idx] = 0
		
		apply_kernel(mouse_pos_grid, 0.0)
		
		update_colors()	
		draw_grid_lines()
