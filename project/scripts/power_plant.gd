extends Node2D

@onready var particle_simulation: Node2D = $"../ParticleSimulation"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var particles = particle_simulation.get("SIM").get_particle_positions()

	for p in particles:
		if $TextureRect.get_global_rect().has_point(p):
			print("Point is in boundary")
