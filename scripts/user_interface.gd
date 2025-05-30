extends Control

@onready var canvas_layer = $CanvasLayer
@onready var pause = $"CanvasLayer/Pause Menu"
@onready var information = $CanvasLayer/Information
@onready var fps_label = $CanvasLayer/FPS as RichTextLabel
@onready var settings_menu = $"CanvasLayer/Settings Menu"
@onready var progress_bar = $CanvasLayer/ProgressBar
@onready var tooltip = $CanvasLayer/Tooltip
var pause_menu := false
var lowest_fps = INF
var highest_fps = -INF

func _ready():
	if GameState.show_fps:
		fps_label.show()
	else:
		fps_label.hide()

func _process(_delta):
	if GameState.show_fps:
		fps_label.show()
		var current_fps = Engine.get_frames_per_second()
		if GameState.extended_fps:
			if current_fps < lowest_fps:
				lowest_fps = current_fps
			if current_fps > highest_fps:
				highest_fps = current_fps
			fps_label.text = "Fps: [color=red]%d[/color] / %d / [color=green]%d[/color] " % [lowest_fps, current_fps, highest_fps]
		else:
			fps_label.text = "Fps: %d" % current_fps
	else:
		fps_label.hide()

func _input(event):
	if event.is_action_pressed("escape") and get_tree().current_scene.name != "Main Menu":
		toggle_pause_menu()

func toggle_pause_menu():
	pause_menu = !pause_menu
	if pause_menu:
		information.hide()
		pause.show()
		settings_menu.hide()
		Engine.time_scale = 0
	else:
		information.show()
		pause.hide()
		settings_menu.hide()
		Engine.time_scale = 1

func _on_resume_pressed():
	toggle_pause_menu()

func _on_exit_main_menu_pressed():
	toggle_pause_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_desktop_pressed():
	get_tree().quit()

func _on_settings_pressed():
	pause.visible = false
	Engine.time_scale = 0
	settings_menu.show()
