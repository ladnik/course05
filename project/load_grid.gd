extends Node2D

const PI = 3.14159265358979323846

const TILE_SIZE = 16  # Specify the tile side length here

var grid = []

var tiles = []

var _width = -1
var _height = -1

# measured in tiles
var kernel_radius = 5

func create_empty_grid(width, height):
	
	_width = width
	_height = height
	
	for y in range(height):
		var grid_row = []
		for x in range(width):
			grid_row.append(0.0)
		grid.append(grid_row)

func _ready():
	#load_grid_from_file("res://grid_data.txt")
	create_empty_grid(100, 100)
	display_grid()
	

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
	
func load_grid_from_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	if file == null:
		print("Error opening file")
		return
	
	# Read dimensions
	var dimensions = file.get_line().split(",")
	_width = int(dimensions[0])
	_height = int(dimensions[1])
	
	# Read grid data
	for y in range(_height):
		var row = file.get_line().split(",")
		var grid_row = []
		for x in range(_width):
			grid_row.append(float(row[x]))
		grid.append(grid_row)
	
	file.close()
	
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

func display_grid():
	
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
		
func update_colors():
	
	for y in range(_height):
				
		for x in range(_width):
			
			tiles[y][x].color = Color(grid[y][x], grid[y][x], grid[y][x])

func to_grid_pos(pixel_pos):
	
	var pixel_x = pixel_pos[0]
	var pixel_y = pixel_pos[1]
	
	var grid_x = pixel_x / TILE_SIZE
	var grid_y = pixel_y / TILE_SIZE
	
	return Vector2(grid_x, grid_y)
	
func on_grid(grid_pos):
	
	return 0 <= grid_pos.x and grid_pos.x < len(grid[0]) and 0 <= grid_pos.y and grid_pos.y < len(grid)

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
		
		
	# remove terrain
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and on_grid(mouse_pos_grid):
		grid[y_idx][x_idx] = 0
		
		apply_kernel(mouse_pos_grid, 0.0)
		
		update_colors()	
		
		
func _draw():
	
	draw_grid_lines()
	
	queue_redraw()
	
