extends Node2D

var direction: Vector2 = Vector2(0, 1)
var normal: Vector2 = Vector2(1, 0)
var initial_velocity: float = 0
var width: int = 0
var spawn_interval: float = 0.2
var timer = 0.0
var global_time = 0.0
var num_particles = 1
var start_time = 0.0
var stop_time = 1.0


func _init(source_position: Vector2, direction: Vector2, velocity: float, width: int, spawn_interval: float, num_particles: int, start_time: float, stop_time:float) -> void:
	self.position = source_position
	self.direction = direction.normalized()
	self.initial_velocity = velocity
	self.width = width
	self.spawn_interval = spawn_interval
	self.num_particles = num_particles
	self.normal = Vector2(direction.y, -direction.x)
	self.start_time = start_time
	self.stop_time = stop_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spawn(delta: float, particle_positions, previous_positions, velocities, forces) -> void:
	timer += delta
	global_time += delta
	if timer > spawn_interval and global_time > start_time and global_time < stop_time:
		timer = 0
		for i in range(num_particles):
			var offset = -self.normal * width / 2.0 + self.normal * width / (num_particles - 1) * i if num_particles > 1 else Vector2(0,0)
			var particle_position = self.position + offset
			particle_positions.push_back(particle_position)
			previous_positions.push_back(particle_position)
			velocities.push_back(self.direction * initial_velocity)
			forces.push_back(Vector2(0,0))

func _draw() -> void:
	draw_line(position - normal * width / 2.0, position + normal * width / 2.0, Color(1, 0, 0), 1, false)
		
