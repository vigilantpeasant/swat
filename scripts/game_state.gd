extends Node
var selected_weapon := "rifle"
var vsync := true
var show_fps := true
var extended_fps := true

var no_flashlight := false

var interact_key = "E"
var flashbang_key = "G"
var tooltip_mode := "" # door, handcuff

func _ready():
	update_interact_key()
	update_flashbang_key()

func update_interact_key():
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey:
			interact_key = OS.get_keycode_string(event.physical_keycode)

func update_flashbang_key():
	for event in InputMap.action_get_events("grenade"):
		if event is InputEventKey:
			flashbang_key = OS.get_keycode_string(event.physical_keycode)
