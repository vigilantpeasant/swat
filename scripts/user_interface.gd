extends Control

@onready var canvas_layer := $CanvasLayer
@onready var pause := $"CanvasLayer/Pause Menu"
@onready var fps_label := $CanvasLayer/FPS as RichTextLabel
@onready var settings_menu := $"CanvasLayer/Settings Menu"
@onready var end_level := $"CanvasLayer/End Level"
#
@onready var health_panel := $CanvasLayer/Health
@onready var health_label := $CanvasLayer/Health/Health
@onready var progress_bar := $CanvasLayer/ProgressBar
@onready var tooltip := $CanvasLayer/Tooltip
@onready var information := $CanvasLayer/Information
@onready var flashbang_panel := $CanvasLayer/Flashbang
@onready var flashbang_label := $CanvasLayer/Flashbang/Flashbang
@onready var flashlight_label := $CanvasLayer/Flashlight_label
@onready var weapon_selection := $"CanvasLayer/Weapon Selection"
@onready var objectives := $CanvasLayer/Objectives
#
@onready var sfx_bus := AudioServer.get_bus_index("SFX")
@onready var settings := $"CanvasLayer/Settings Menu/Settings"
@onready var player := get_parent().get_node("Player")
@onready var rifle := $"CanvasLayer/Weapon Selection/Rifle"
@onready var smg := $"CanvasLayer/Weapon Selection/SMG"

var hide_ws_interval := 3.0
var ws_timer := 0.0
var ws_visible := true

var end_menu := false
var pause_menu := false
var lowest_fps := INF
var highest_fps := -INF

func _ready():
	if GameState.show_fps:
		fps_label.show()
	else:
		fps_label.hide()
	
	if GameState.selected_weapon == "rifle":
		rifle.show()
		smg.hide()
	elif GameState.selected_weapon == "submachine":
		rifle.hide()
		smg.show()
	start_ws_hide_timer()
	Engine.time_scale = 1
	await get_tree().create_timer(0.5).timeout
	handle_node_count()

func _process(_delta):
	handle_fps_label()
	handle_node_count()
	health_label.text = "Health: %s" % player.breakable.health
	flashbang_label.text = str(player.flashbang_count)

func _input(event):
	if event.is_action_pressed("escape") and get_tree().current_scene.name != "Main Menu" and not end_menu:
		if settings_menu.visible:
			information.hide()
			flashbang_panel.hide()
			flashlight_label.hide()
			weapon_selection.hide()
			tooltip.hide()
			progress_bar.hide()
			objectives.hide()
			health_panel.hide()
			pause.show()
			settings_menu.hide()
			Engine.time_scale = 0
			return
		toggle_pause_menu()
	if event.is_action_pressed("mute"):
		GameState.sfx = not GameState.sfx
		AudioServer.set_bus_mute(sfx_bus, not GameState.sfx)
		settings.update_ui()

func handle_node_count():
	var active_civilians := 0
	var active_suspects := 0
	GameState.handcuffed_civilian = 0
	GameState.neutralized_suspect = 0
	GameState.arrested_suspect = 0
	GameState.unauthorized_force = 0
	GameState.people_killed_by_suspects = 0
	
	for civilian in get_tree().get_nodes_in_group("Civilian"):
		if civilian.dead and civilian.who_killed_me == "Player":
			GameState.unauthorized_force += 1
		elif civilian.handcuffed:
			GameState.handcuffed_civilian += 1
		elif civilian.who_killed_me == "Suspect":
			GameState.people_killed_by_suspects += 1
		else:
			active_civilians += 1
	
	for suspect in get_tree().get_nodes_in_group("Suspect"):
		if suspect.dead and suspect.who_killed_me == "Player":
			if suspect.personality == "Calm":
				GameState.unauthorized_force += 1
			else:
				GameState.neutralized_suspect += 1
		elif suspect.handcuffed:
			GameState.arrested_suspect += 1
		elif suspect.who_killed_me == "Suspect":
			GameState.people_killed_by_suspects += 1
		else:
			active_suspects += 1
	
	if active_civilians == 0 and active_suspects == 0:
		handle_end_level("Objective")
		player.camera_2d.reset_trauma()
	objectives.text = "Handcuff Civilians (%s Left)\nArrest Suspects (%s Left)" % [active_civilians, active_suspects]

func handle_end_level(action : String):
	if action == "Killed":
		end_level.handle_result("Killed")
	elif action == "Objective":
		end_level.handle_result("Objective")
	end_menu = true
	end_level.show()
	information.hide()
	flashbang_panel.hide()
	flashlight_label.hide()
	weapon_selection.hide()
	tooltip.hide()
	health_panel.hide()
	progress_bar.hide()
	objectives.hide()
	Engine.time_scale = 0

func start_ws_hide_timer():
	await get_tree().create_timer(hide_ws_interval).timeout
	if not pause_menu and ws_visible:
		hide_ws()

func handle_fps_label():
	if GameState.show_fps:
		fps_label.show()
		var current_fps := Engine.get_frames_per_second()
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

func toggle_pause_menu():
	reset_ws_timer()
	pause_menu = !pause_menu
	if pause_menu:
		information.hide()
		flashbang_panel.hide()
		flashlight_label.hide()
		weapon_selection.hide()
		tooltip.hide()
		progress_bar.hide()
		objectives.hide()
		health_panel.hide()
		pause.show()
		settings_menu.hide()
		Engine.time_scale = 0
	else:
		information.show()
		flashbang_panel.show()
		flashlight_label.show()
		weapon_selection.show()
		tooltip.show()
		progress_bar.show()
		objectives.show()
		health_panel.show()
		pause.hide()
		settings_menu.hide()
		Engine.time_scale = 1

func reset_ws_timer():
	ws_timer = 0.0
	if not ws_visible:
		show_ws()
		start_ws_hide_timer()

func hide_ws():
	ws_visible = false
	weapon_selection.hide()

func show_ws():
	ws_visible = true
	weapon_selection.show()

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

func _on_restart_pressed():
	var current_scene_path := get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene_path)
