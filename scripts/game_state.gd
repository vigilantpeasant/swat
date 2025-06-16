extends Node

var selected_weapon := "rifle"
var initial_primary_weapon := "rifle"
var sfx := true
var vsync := true
var show_fps := true
var extended_fps := true

var no_flashlight := false
var no_casualities := false
var flashbang_count := 3

var interact_key := "E"
var flashbang_key := "RMB"
var tooltip_mode := ""

var handcuffed_civilian := 0
var neutralized_suspect := 0
var arrested_suspect := 0
var unauthorized_force := 0
var people_killed_by_suspects := 0
var collected_evidence := 0

func _ready():
	update_interact_key()
	update_flashbang_key()

func update_interact_key():
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey:
			interact_key = OS.get_keycode_string(event.physical_keycode)
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					interact_key = "LMB"
				MOUSE_BUTTON_RIGHT:
					interact_key = "RMB"
				MOUSE_BUTTON_MIDDLE:
					interact_key = "MMB"
				_:
					interact_key = "Mouse " + str(event.button_index)

func update_flashbang_key():
	for event in InputMap.action_get_events("grenade"):
		if event is InputEventKey:
			flashbang_key = OS.get_keycode_string(event.physical_keycode)
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					flashbang_key = "LMB"
				MOUSE_BUTTON_RIGHT:
					flashbang_key = "RMB"
				MOUSE_BUTTON_MIDDLE:
					flashbang_key = "MMB"
				_:
					flashbang_key = "Mouse " + str(event.button_index)
