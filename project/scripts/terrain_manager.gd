extends Node2D

const TILE_SIZE = 5  # Specify the tile side length here

var width = 200
var height = 50

var grid : Array = []
var gridNoise = FastNoiseLite.new()


func _ready():
	generateGrid()
	#renderGrid()

func generateGrid():
	var returnBoundaries : Array[PackedVector2Array] = [] # all boundaries
	var boundary : PackedVector2Array = [] # current boundary

	# Generate grid array
	for y in range(height):
		var grid_row = []
		for x in range(width):
			grid_row.append(0)
		grid.append(grid_row)

	# Initialize noise generator
	gridNoise.seed = 0815;
	gridNoise.noise_type = FastNoiseLite.TYPE_PERLIN
	gridNoise.fractal_octaves = 4
	gridNoise.frequency = 0.0075

	# Fill grid with noise data and generate output boundaries
	for x in range(width):
		var maxHeight = round(gridNoise.get_noise_1d(x) * height * 2 + height / 2.5)

		boundary.append(Vector2(x, maxHeight))

		#print(maxHeight)
		for y in range(height):
			if maxHeight <= y:
				grid[y][x] = 1.0
		
	for x in range(50, 100):
		for y in range(40, 50):
			grid[y][x] = 0.0

	# Genereate the two bottom points
	boundary.append(Vector2(width - 1, height - 1))
	boundary.append(Vector2(0, 		   height - 1))

	returnBoundaries.append(boundary)

	return returnBoundaries


func renderGrid(): 
	for y in range(height):
		for x in range(width):
			var tile = ColorRect.new()
			tile.size = Vector2(TILE_SIZE, TILE_SIZE)
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			#tile.color = Color.GRAY if grid[y][x] == 1 else Color.SKY_BLUE
			tile.color = Color.GRAY if grid[y][x] else Color.SKY_BLUE
			add_child(tile)

# func _draw():
# 	# Draw grid lines
# 	for y in range(len(grid) + 1):
# 		draw_line(Vector2(0, y * TILE_SIZE), Vector2(len(grid[0]) * TILE_SIZE, y * TILE_SIZE), Color.BLACK)
# 	for x in range(len(grid[0]) + 1):
# 		draw_line(Vector2(x * TILE_SIZE, 0), Vector2(x * TILE_SIZE, len(grid) * TILE_SIZE), Color.BLACK)
