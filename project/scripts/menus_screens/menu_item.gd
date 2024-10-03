extends Label

@export var box : ColorRect

func _on_mouse_entered() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if box != null:
		tween.parallel().tween_property(box, "scale", Vector2(1.1, 1.1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "label_settings:font_color", Color.from_string("33acbe",Color.CYAN), 0.1)
	tween.bind_node(self)

func _on_mouse_exited() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if box != null:
		tween.parallel().tween_property(box, "scale", Vector2(1, 1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "label_settings:font_color", Color.WHITE, 0.1)
	tween.bind_node(self)
