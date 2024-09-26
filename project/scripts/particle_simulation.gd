extends RefCounted

# import terrrain manager script to access the terrain data
#const TERRAIN_MANAGER = preload("res://scripts/terrain_manager.gd")
var Constants = load('res://scripts/simulation_constants.gd')
var Particle = load('res://scripts/Particle.gd')



var particles : Array = []
var gravity_vector: Vector2 = Vector2(0, Constants.GRAVITY)


# Called when the node enters the scene tree for the first time.

func _init():
	
	
	for i in range(Constants.NUMBER_PARTICLES):
		var pos: Vector2 = Vector2(200+i*200,0)
		var vel: Vector2= Vector2(50,10)
		
		particles.append(Particle.new(pos,vel))



func update(delta, draw_mode=Constants.DRAW_MODE_BLOB):
	pass
	#var m = OS.get_ticks_msec()
	
	#find_neighborhoods()
	#print('find_neighborhoods takes ' + str(OS.get_ticks_msec() - m) + ' ms.')
	#m = OS.get_ticks_msec()
	
	#calculate_density()
	#calculate_pressure()
	#calculate_force_density(draw_mode)
	integration_step(delta)
	#collision_handling()
	
	#breakpoint
	#grid.update_structure(particles)
	
	#print('everything else takes ' + str(OS.get_ticks_msec() - m) + ' ms.')
	#m = OS.get_ticks_msec()



func integration_step(delta):
	for i in range(Constants.NUMBER_PARTICLES):
		particles[i].velocity += delta * gravity_vector
		particles[i].position += delta * particles[i].velocity
		

func collsison_reflection(normal_vector: Vector2):
	pass
	
