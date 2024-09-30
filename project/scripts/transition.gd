extends CanvasLayer

var fadetime := 0.2
@onready var rect : ColorRect = $rect
		
func fade_to_black():
	# Animate alpha value from 0 to 1 in 1.0 seconds (fully opaque)
	var tween : Tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1, fadetime).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	tween.kill()
	
func fade_to_normal():
	# Animate alpha value from 1 to 0 in 1.0 seconds (fully transparent)
	var tween : Tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0, fadetime).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	tween.kill()
	
func transition_effect(scene):
	await fade_to_black()
	get_tree().change_scene_to_file(scene)
	#get_tree().paused = true
	await fade_to_normal()
	#get_tree().paused = false
