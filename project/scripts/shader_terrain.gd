extends Sprite2D

@onready var renderer = $"../TerrainRenderer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func visualize(grid : Array) -> void:
	var img = Image.create(len(grid[0]), len(grid), false, Image.FORMAT_R8)  # Create a 256x256 single channel image (8-bit)

	for y in range(len(grid)):
		for x in range(len(grid[0])):
			img.set_pixel(x, y, Color(grid[y][x], 0, 0, 1))

	print(img)
	var itex = ImageTexture.create_from_image(img)
	print(img.get_width())
	print(img.get_height())
	print(itex)
	print(itex.get_width())
	print(itex.get_height())
	
    # Assign texture to the shader
	var dtex = load("res://assets/levelBackground_dummy.png") as Texture2D
	self.texture = itex
	material.set_shader_parameter("x_size", len(grid[0]) - 1)
	material.set_shader_parameter("y_size", len(grid) - 1)

	position.x = len(grid[0]) / 2 * 8
	position.y = len(grid) / 2*8
	scale.x = 8
	scale.y = 8

	print(position)
	print(scale)

