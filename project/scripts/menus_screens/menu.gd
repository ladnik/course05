extends CanvasLayer

@onready var click_music: AudioStreamPlayer = $ClickMusic
@export var stream: AudioStream
@onready var background_scene: VideoStreamPlayer = $BackgroundScene

@onready var intro_scene: VideoStreamPlayer = $IntroScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	AudioManager.play_main_menu_music()
	if intro_scene != null:
		intro_scene.finished.connect(_on_intro_scene_finished)
	

func start_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/levels/level1.tscn")

func level_gui(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/menus_screens/level_menu.tscn")

func exit_gui_event(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().quit()

func _on_credits_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/menus_screens/credits.tscn")

func tutorial_gui(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		TransitionScene.transition_effect("res://scenes/menus_screens/tutorial.tscn")


func _on_intro_scene_click(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		print("clicked")
		if intro_scene != null and intro_scene.paused == true:
			animation_player.play("buttons_in")
			intro_scene.paused = false

func _on_intro_scene_finished():
	background_scene.play()
