extends Control

@onready var level_selection := $"Level Selection"
@onready var settings := $Settings

var settings_scene := preload("res://scenes/settings.tscn")

func _ready():
	settings._on_reset_to_default_pressed()

func _on_play_pressed():
	level_selection.show()
	settings.hide()

func _on_settings_pressed():
	level_selection.hide()
	settings.show()

func _on_exit_pressed():
	get_tree().quit()
