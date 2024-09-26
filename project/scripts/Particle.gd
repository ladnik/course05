extends RefCounted
var Constants = load('res://scripts/simulation_constants.gd')

var position = Vector2()
var velocity = Vector2()
var force = Vector2()

var mass = Constants.PARTICLE_MASS

var density = 0
var pressure = 0
var viscosity = 0

func _init(pos = Vector2(),vel = Vector2()):
	#set initial position and velocity
	position = pos
	velocity = vel

func get_color(draw_mode):
	var color = 1
	match draw_mode:
			Constants.DRAW_MODE_PRESSURE:
				color = pressure / 100.0
			Constants.DRAW_MODE_VISCOSITY:
				color = viscosity / 500.0
	
	return Color(color, color, color)
