extends Node2D

var backgroundImage
var backgroundTexture
var backgroundSprite = Sprite2D.new()

var backgroundNoise = FastNoiseLite.new()

var _width = 1000
var _height = 1000

# Basic functions
var palette = [Color8(251, 190, 171, 255), Color8(251, 192, 185, 255), Color8(253, 166, 165, 255), Color8(227, 137, 143, 255), Color8(224, 129, 145, 255), Color8(145, 86, 107, 255), Color8(125, 81, 104, 255), Color8(103, 75, 98, 255)]

# Renderer functions

func update_grid():
	for y in range(_height):
		for x in range(_width):
			var value = (backgroundNoise.get_noise_2d(x / 10.0, y / 10.0) + 1) / 2
			value = clamp(value, 0.0, 1.0)

			backgroundImage.set_pixel(x, y, palette[int(roundf(value * 7.0))])
	backgroundTexture.update(backgroundImage)
	pass

func updateWindowSize(scale): 
	var windowSize = get_viewport_rect().size
	backgroundSprite.scale = scale
	

func initialize(scale):
	# Initialize noise generator
	backgroundNoise.seed = 0815;
	backgroundNoise.noise_type = FastNoiseLite.TYPE_CELLULAR
	backgroundNoise.fractal_octaves = 0
	backgroundNoise.fractal_type = FastNoiseLite.FRACTAL_NONE
	backgroundNoise.frequency = 0.75 / 2.0

	backgroundNoise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN
	backgroundNoise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	backgroundNoise.cellular_jitter = 0.8

	backgroundImage = Image.create(_width, _height, false, Image.FORMAT_RGB8)
	backgroundTexture = ImageTexture.create_from_image(backgroundImage)

	backgroundSprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	backgroundSprite.texture = backgroundTexture	
	backgroundSprite.offset = Vector2(_width / 2.0, _height / 2.0)

	update_grid()

	updateWindowSize(scale)


# Godot functions

func _ready() -> void:
	get_tree().root.size_changed.connect(updateWindowSize)

	add_child(backgroundSprite)

func _process(delta: float) -> void:
	pass
