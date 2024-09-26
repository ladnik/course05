extends Label

func _on_mouse_entered() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_BOUNCE)

func _on_mouse_exited() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_BOUNCE)
