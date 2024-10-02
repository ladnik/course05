extends Sprite2D

@onready var simulation = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#print("visualization exists")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print(simulation.SIM.get_particle_positions())
