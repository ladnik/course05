extends Sprite2D

@onready var simulation = $".."
@onready var terrain = $"../../TerrainManager/TerrainEditor"
var stored_grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
