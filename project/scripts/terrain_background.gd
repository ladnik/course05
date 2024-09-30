extends Node2D

var backgroundNoise = FastNoiseLite.new()

var _width = DisplayServer.window_get_size().x
var _height = DisplayServer.window_get_size().y

# Basic functions
var palette = [Color8(251, 190, 171, 255), Color8(251, 192, 185, 255), Color8(253, 166, 165, 255), Color8(227, 137, 143, 255), Color8(224, 129, 145, 255), Color8(145, 86, 107, 255), Color8(125, 81, 104, 255), Color8(103, 75, 98, 255)]

var waterPalette = [Color8(110, 187, 189, 255), Color8(182, 235, 236, 255), Color8(146, 233, 240, 255), Color8(131, 218, 222, 255), Color8(107, 220, 231, 255), Color8(80, 216, 221, 255), Color8(45, 132, 158, 255), Color8(37, 119, 148, 255)]
# Renderer functions

func create_texture(paletteNumber : int) -> Texture2D:
	# Initialize noise generator
	backgroundNoise.seed = 0815
	backgroundNoise.noise_type = FastNoiseLite.TYPE_CELLULAR
	backgroundNoise.fractal_octaves = 0
	backgroundNoise.fractal_type = FastNoiseLite.FRACTAL_NONE
	backgroundNoise.frequency = 0.75 / 2.0

	backgroundNoise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN
	backgroundNoise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	backgroundNoise.cellular_jitter = 0.8

	var backgroundImage = Image.create(_width, _height, false, Image.FORMAT_RGB8)
	var backgroundTexture = ImageTexture.create_from_image(backgroundImage)

	var currentPalette = palette if paletteNumber == 0 else waterPalette
	for y in range(_height):
		for x in range(_width):
			var value = (backgroundNoise.get_noise_2d(x / 10.0, y / 10.0) + 1) / 2
			value = clamp(value, 0.0, 1.0)
			
			var val : int = value * 255
			var color
			#color = Color8(val, val, val, 255) 
			color = currentPalette[int(roundf(value * 7.0))]
			#color.darkened(round(y / 400.0) / 10.0))
			backgroundImage.set_pixel(x, y, color)
	backgroundTexture.update(backgroundImage)
	
	return backgroundTexture
