extends Node2D

class_name PowerPlant

var particle_simulation
var score : int = 0
@export var power_needed: int


func _ready() -> void:
	score = 0

func set_particle_simulation(_particle_simulation : ParticleSimulation):
	particle_simulation = _particle_simulation.SIM

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if particle_simulation == null:
		return
	var particles = particle_simulation.get_particle_positions()
	var to_remove = Array()

	var i = 0
	for p in particles:
		if $TextureRect.get_global_rect().has_point(p):
			produce_power()
			to_remove.append(i)
		i += 1
	for j in to_remove.size():
		particle_simulation.delete_particle(to_remove[j])

func produce_power():
	score += 1
	print("Your score: " + str(score))
	if score > power_needed:
		TransitionScene.transition_effect("res://scenes/menus_screens/win_screen.tscn")
		queue_free()
	
