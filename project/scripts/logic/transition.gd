extends CanvasLayer

var fadetime := 0.2
@onready var rect : ColorRect = $rect
var prevscene = ""
var presentscene = ""
		
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
	
func transition_effect(scene: String) -> void:
	# Get the current scene
	var current_scene = get_tree().current_scene
	
	# Only update prevscene if the current scene is valid
	if current_scene and current_scene.has_method("get_scene_file"):
		# Check if the scene is a win or lose screen
		if current_scene.get_scene_file() != "res://scenes/menus_screens/win_screen.tscn" and current_scene.get_scene_file() != "res://scenes/menus_screens/lose_screen.tscn":
			prevscene = current_scene.get_scene_file()
			
	# Check if transitioning to win screen or lose screen to avoid playing click sound
	if scene != "res://scenes/menus_screens/win_screen.tscn" and scene != "res://scenes/menus_screens/lose_screen.tscn" and scene != "res://scenes/menus_screens/after_final_level.tscn":
		AudioManager.play_click_sound()
		
	# Perform the fade to black, change scene, and fade to normal
	await fade_to_black()
	get_tree().change_scene_to_file(scene)
	
	# Play the appropriate music based on the scene transitioning to
	if scene == "res://scenes/menus_screens/win_screen.tscn":
		AudioManager.handle_win_screen_transition()
	if scene == "res://scenes/menus_screens/after_final_level.tscn":
		AudioManager.handle_win_screen_transition()
	elif scene == "res://scenes/menus_screens/lose_screen.tscn":
		AudioManager.handle_lose_screen_transition()
	#elif scene == "res://scenes/menus_screens/menu.tscn":
	#	AudioManager.play_main_menu_music()  # Ensure main menu music plays when transitioning to the menu

	await fade_to_normal()

	# After transitioning, update prevscene if not a win/lose screen
	if scene != "res://scenes/menus_screens/win_screen.tscn" and scene != "res://scenes/menus_screens/lose_screen.tscn":
		prevscene = scene
		
func reset_prevscene():
	prevscene = ""  # Reset previous scene when necessary (e.g., on main menu load)
	
func transition_effect_for_reload():
	await fade_to_black()
	get_tree().reload_current_scene()
	await fade_to_normal()
