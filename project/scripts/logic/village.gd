extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var particle_simulation
var rect : Rect2

var flow_count : int = 0
var critical_timeframes = 0
@export var timeframes_to_monitor = 5
@export var flow_threshold = 5

signal village_destroyed

func _ready():
	var rectangle_shape = collision_shape_2d.shape as RectangleShape2D
	var extents = rectangle_shape.extents  # Vector2 representing half the size
	rect = Rect2(collision_shape_2d.global_position, rectangle_shape.size)


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
		if rect.has_point(p):
			flow_count += 1
			show_hit_effect()
			to_remove.append(i)
		i += 1
	particle_simulation.delete_particles(to_remove)


func _on_flow_timer_timeout() -> void:
	if flow_count >= flow_threshold:
		critical_timeframes += 1
		print("critical!")
		#show_hit_effect()
	if critical_timeframes >= timeframes_to_monitor:
		emit_signal("village_destroyed")
			
func show_hit_effect():
	$Area2D/VillageHut.modulate = Color(1, 0.5, 0.5)  # Apply a red tint
	await get_tree().create_timer(0.75).timeout
	$Area2D/VillageHut.modulate = Color(1, 1, 1)  # Reset to normal color
