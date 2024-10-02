extends Sprite2D

@onready var simulation = $".."
@onready var terrain = $"../../TerrainManager/TerrainEditor"
var stored_grid
var rng = RandomNumberGenerator.new()
var colors = [
    Color(1.0, 0.82, 0.86, 1),  # Light Pink
    Color(0.8, 1.0, 0.9, 1),    # Mint Green
    Color(0.9, 0.9, 0.98, 1),   # Lavender
    Color(1.0, 0.99, 0.82, 1),  # Light Yellow
    Color(0.88, 0.94, 1.0, 1),  # Baby Blue
    Color(1.0, 0.89, 0.77, 1),  # Peach
    Color(0.85, 0.75, 0.85, 1), # Thistle
    Color(0.94, 1.0, 0.94, 1),  # Honeydew
    Color(0.96, 0.87, 0.7, 1),  # Light Orange
    Color(0.87, 0.98, 0.91, 1), # Mint Cream
    Color(0.95, 0.87, 0.95, 1), # Light Purple
    Color(0.93, 0.9, 0.79, 1)   # Light Khaki
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var voronoi_img = Image.create(10, 1, false, Image.FORMAT_RGBA8)
	for i in range(10):
		voronoi_img.set_pixel(i, 0, colors[i])
	var itex = ImageTexture.create_from_image(voronoi_img)
	material.set_shader_parameter("voronoi_colors", itex)
	var voronoi_points = PackedVector2Array()
	voronoi_points.resize(128)
	for i in range(len(voronoi_points)):
		voronoi_points[i] = Vector2(rng.randf_range(0.0, 1920.0), rng.randf_range(0.0, 1080.0))
	material.set_shader_parameter("voronoi_centers", voronoi_points)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	stored_grid = terrain.grid
	visualize(stored_grid)

func visualize(grid : Array) -> void:
	stored_grid = grid
	var img = Image.create(len(grid[0]), len(grid), false, Image.FORMAT_R8)  # Create a 256x256 single channel image (8-bit)

	for y in range(len(grid)):
		for x in range(len(grid[0])):
			img.set_pixel(x, y, Color(grid[y][x], 0, 0, 1))

	var itex = ImageTexture.create_from_image(img)
	self.texture = itex
	material.set_shader_parameter("x_size", len(grid[0]) - 1)
	material.set_shader_parameter("y_size", len(grid) - 1)

	position.x = len(grid[0]) / 2 * 15 - 7.5
	position.y = len(grid) / 2*15 - 7.5
	scale.x = 15
	scale.y = 15

	var particle_positions = simulation.SIM.get_particle_positions()
	var padding = PackedVector2Array()
	padding.resize(2048 - len(particle_positions))
	var padded_particle_positions = particle_positions + padding
	material.set_shader_parameter("num_particles", len(particle_positions))
	material.set_shader_parameter("particle_positions", particle_positions)
