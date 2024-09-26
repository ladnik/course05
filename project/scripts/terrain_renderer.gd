extends Node2D

static var gridImage
static var gridTexture
static var gridSprite = Sprite2D.new()

static var _width = -1
static var _height = -1

# Basic functions

func to_grid_pos(pixel_pos):
	return pixel_pos / gridSprite.scale


# Renderer functions

func update_grid(grid):
	for y in range(_height):
		for x in range(_width):
			gridImage.set_pixel(x, y, Color(grid[y][x], grid[y][x], grid[y][x]))
	gridTexture.update(gridImage)

func updateWindowSize(): 
	var windowSize = get_viewport_rect().size
	var scaleY = windowSize.y / _height
	gridSprite.scale = Vector2(scaleY, scaleY)

func initialize(grid):
	_height = len(grid)
	_width = len(grid[0])

	gridImage = Image.create(_width, _height, false, Image.FORMAT_RGB8)
	gridTexture = ImageTexture.create_from_image(gridImage)

	gridSprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	gridSprite.texture = gridTexture	
	gridSprite.offset = Vector2(_width / 2.0, _height / 2.0)

	update_grid(grid)


# Godot functions

func _draw() -> void:
	get_tree().root.size_changed.connect(updateWindowSize)
	updateWindowSize()

	add_child(gridSprite)

func _process(delta: float) -> void:
	pass
