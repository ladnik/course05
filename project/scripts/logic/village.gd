extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var progress_bar = $ProgressBar

var particle_simulation
var rect : Rect2

var flow_count : int = 0
var critical_timeframes = 0
@export var timeframes_to_monitor = 5
@export var flow_threshold = 5

var sb = StyleBoxFlat.new()

signal village_destroyed

func _ready():
	$ProgressBar.add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color("33acbe")
	sb.set_corner_radius_all(5)
	var rectangle_shape = collision_shape_2d.shape as RectangleShape2D
	var extents = rectangle_shape.extents  # Vector2 representing half the size
	rect = Rect2(collision_shape_2d.global_position, rectangle_shape.size)
	progress_bar.step = progress_bar.max_value / timeframes_to_monitor


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
			AudioManager.start_village()
			flow_count += 1
			show_hit_effect()
			to_remove.append(i)
		i += 1
		AudioManager.stop_village()
	particle_simulation.delete_particles(to_remove)


func _on_flow_timer_timeout() -> void:
	if flow_count > 0:
		$ProgressBar.visible = true
	if progress_bar.value != 100:
		if flow_count >= flow_threshold:
			progress_bar.value += progress_bar.step
		else:
			progress_bar.value -= progress_bar.step

	if flow_count >= flow_threshold:
		critical_timeframes += 1
		#print("critical!")
		#show_hit_effect()
	if critical_timeframes >= timeframes_to_monitor:
		sb.bg_color = Color("91556b")
		emit_signal("village_destroyed")
			
func show_hit_effect():
	$Area2D/VillageHut.modulate = Color(1, 0.5, 0.5)  # Apply a red tint
	await get_tree().create_timer(0.75).timeout
	$Area2D/VillageHut.modulate = Color(1, 1, 1)  # Reset to normal color
