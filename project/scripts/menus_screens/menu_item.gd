extends Label

@export var box : ColorRect
var hover_color : Color = Color("33acbe")
var default_color : Color = Color.WHITE

func _on_mouse_entered() -> void:
	var tween : Tween = get_tree().create_tween()

	# scale the label
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# scale the box ColorRect if it exists
	if box != null:
		tween.parallel().tween_property(box, "scale", Vector2(1.1, 1.1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Change the label text color
	tween.parallel().tween_property(self, "modulate", hover_color, 0.1)

func _on_mouse_exited() -> void:
	var tween : Tween = get_tree().create_tween()

	# reset label scale
	tween.tween_property(self, "scale", Vector2(1, 1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# reset box ColorRext scale if it exists
	if box != null:
		tween.parallel().tween_property(box, "scale", Vector2(1, 1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Revert label text color to default
	tween.parallel().tween_property(self, "modulate", default_color, 0.1)
