extends Control
@onready var panel = $Panel
@onready var level_selection = $"Level Selection"
@onready var settings = $Settings
var settings_scene = preload("res://scenes/settings.tscn")

func _ready():
	panel.show()
	settings._on_reset_to_default_pressed()

func _on_play_pressed():
	panel.hide()
	settings.hide()
	level_selection.show()

func _on_settings_pressed():
	panel.hide()
	settings.show()
	level_selection.hide()

func _on_exit_pressed():
	get_tree().quit()
