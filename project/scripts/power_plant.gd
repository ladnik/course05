extends Node2D

@onready var particle_simulation: Node2D = $"../ParticleSimulation"
var SIM
var score : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SIM = particle_simulation.get("SIM")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var particles = SIM.get_particle_positions()
	var to_remove = Array()

	var i = 0
	for p in particles:
		if $TextureRect.get_global_rect().has_point(p):
			producePower()
			to_remove.append(i)
		i += 1
	for j in to_remove.size():
		SIM.remove_particle(to_remove[j])

func producePower():
	score += 1
	print("Your score: " + str(score))
	if score > 35:
		TransitionScene.transition_effect("res://scenes/win_screen.tscn")
	
