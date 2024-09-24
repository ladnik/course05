extends CanvasLayer

func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/test_level.tscn")


func _on_level_overview_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_menu.tscn")
