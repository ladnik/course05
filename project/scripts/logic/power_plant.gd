extends Node2D

class_name PowerPlant

@onready var wheel: Sprite2D = $Wheel
@onready var progress_bar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var particle_simulation
var done : bool = false

var flow_count : int
var flow_counts = []
@export var timeframes_to_monitor = 5
@export var flow_threshold = 15
var fill_color : Color = Color("33acbe")
var filled_color : Color = Color("91556b") ## f3f53c

var sb = StyleBoxFlat.new()

signal enough_water_flow

func _ready() -> void:
	$ProgressBar.add_theme_stylebox_override("fill", sb)
	sb.bg_color = fill_color
	sb.set_corner_radius_all(5)
	progress_bar.step = progress_bar.max_value / timeframes_to_monitor

func set_particle_simulation(_particle_simulation : ParticleSimulation):
	particle_simulation = _particle_simulation.SIM

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if particle_simulation == null or done:
		return
	var particles = particle_simulation.get_particle_positions()
	var to_remove = PackedInt32Array()

	var i = 0
	for p in particles:
		if $TextureRect.get_global_rect().has_point(p):
			AudioManager.start_electricity()
			flow_count += 1
			wheel.rotate(0.1)
			to_remove.append(i)
		i += 1
		AudioManager.stop_electricity()
	particle_simulation.delete_particles(to_remove)


func is_flow_sufficient() -> bool:
	for count in flow_counts:
		if count < flow_threshold:
			return false
	return true


func _on_flow_timer_timeout() -> void:
	flow_counts.append(flow_count)
	if flow_count > 0:
		$ProgressBar.visible = true
	if !done:
		if flow_count >= flow_threshold:
			progress_bar.value += progress_bar.step
		else:
			progress_bar.value -= progress_bar.step
	flow_count = 0  

	if flow_counts.size() > timeframes_to_monitor:
		flow_counts.pop_front()

	if flow_counts.size() == timeframes_to_monitor:
		if is_flow_sufficient():
			done = true
			sb.bg_color = filled_color
			AudioManager.play_generator_filled_max_sound()
			animation_player.play("continued_rotation")
			emit_signal("enough_water_flow")