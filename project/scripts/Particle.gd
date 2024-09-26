extends RefCounted
var Constants = load('res://scripts/simulation_constants.gd')

var position = Vector2()
var velocity = Vector2()
var force = Vector2()
var last_force = Vector2()


var density = 0
var pressure = 0
var viscosity = 0

func _init(pos = Vector2(),vel = Vector2()):
	#set initial position and velocity
	position = pos
	velocity = vel
