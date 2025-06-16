extends Control

@onready var grid := $TabContainer/Input/GridContainer
@onready var vsync_button := $"TabContainer/Display & Sound/GridContainer/Vsync_button"
@onready var fps_button := $"TabContainer/Display & Sound/GridContainer/Fps_button"
@onready var fps_button_2 := $"TabContainer/Display & Sound/GridContainer/Fps_button2"
@onready var sound_effects_button := $"TabContainer/Display & Sound//GridContainer2/Sound Effects_button"
@onready var sfx_bus := AudioServer.get_bus_index("SFX")
@onready var user_interface

var waiting_for_input := false
var remapping_action := ""
var default_bindings := {
	"up": ["key", KEY_W],
	"down": ["key", KEY_S],
	"right": ["key", KEY_D],
	"left": ["key", KEY_A],
	"reload": ["key", KEY_R],
	"key1": ["key", KEY_1],
	"key2": ["key", KEY_2],
	"interact": ["key", KEY_E],

	"flashlight": ["key", KEY_F],
	"grenade": ["mouse", MOUSE_BUTTON_RIGHT],
}
var banned_keys := [
	KEY_ESCAPE,
	KEY_CAPSLOCK,
	KEY_META,
	KEY_INSERT,
	KEY_ENTER,
	KEY_DELETE,
]

func _ready():
	update_all_buttons()
	connect_buttons()
	update_ui()
	
	if not get_tree().current_scene.name == "Main Menu":
		user_interface = $"../../.."

func update_ui():
	vsync_button.button_pressed = GameState.vsync
	fps_button.button_pressed = GameState.show_fps
	fps_button_2.button_pressed = GameState.extended_fps
	sound_effects_button.button_pressed = GameState.sfx

func connect_buttons():
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Button_"):
			var action_name := child.name.replace("Button_", "")
			child.pressed.connect(func(): _on_remap_button_pressed(action_name))

func _input(event):
	if event.is_action_pressed("escape") and get_tree().current_scene.name == "Main Menu":
		print("settings ayağı")
		var panel := $"../Panel"
		var level_selection := $"../Level Selection"
		panel.show()
		level_selection.hide()
		hide()
	
	if not waiting_for_input:
		return
	
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_DELETE:
			InputMap.action_erase_events(remapping_action)
			update_button(remapping_action)
			call_deferred("update_gamestate_key", remapping_action)
			waiting_for_input = false
			_enable_all_buttons()
			return
		waiting_for_input = false
		_enable_all_buttons()
		if event.physical_keycode in banned_keys:
			update_button(remapping_action)
			return
		InputMap.action_erase_events(remapping_action)
		InputMap.action_add_event(remapping_action, event)
		update_button(remapping_action)
		call_deferred("update_gamestate_key", remapping_action)
		return
		
	if event is InputEventMouseButton and event.pressed:
		waiting_for_input = false
		_enable_all_buttons()
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			update_button(remapping_action)
			return
		InputMap.action_erase_events(remapping_action)
		InputMap.action_add_event(remapping_action, event)
		update_button(remapping_action)
		call_deferred("update_gamestate_key", remapping_action)
		return

func _on_remap_button_pressed(action_name: String):
	if waiting_for_input:
		return
	
	remapping_action = action_name
	waiting_for_input = true
	for child in grid.get_children():
		if child is Button:
			child.disabled = true
	var button := grid.get_node("Button_" + action_name)
	if button:
		button.text = "Press a key..."

func update_button(action_name: String):
	var events := InputMap.action_get_events(action_name)
	var button := grid.get_node("Button_" + action_name)
	if not button:
		return
	
	if events.size() > 0:
		var event := events[0]
		if event is InputEventKey:
			button.text = OS.get_keycode_string(event.physical_keycode)
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					button.text = "Mouse Left"
				MOUSE_BUTTON_RIGHT:
					button.text = "Mouse Right"
				MOUSE_BUTTON_MIDDLE:
					button.text = "Mouse Middle"
				MOUSE_BUTTON_WHEEL_UP:
					button.text = "Wheel Up"
				MOUSE_BUTTON_WHEEL_DOWN:
					button.text = "Wheel Down"
				_:
					button.text = "Mouse Button " + str(event.button_index)
	else:
		button.text = ""

func update_all_buttons():
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Button_"):
			var action_name := child.name.replace("Button_", "")
			update_button(action_name)
			call_deferred("update_gamestate_key", action_name)

func _enable_all_buttons():
	for child in grid.get_children():
		if child is Button:
			child.disabled = false

func _on_back_pressed():
	if get_tree().current_scene.name == "Main Menu":
		var panel := $"../Panel"
		panel.show()
		hide()
	else:
		var pause := $"../../Pause Menu"
		var information := $"../../Information"
		var health := $"../../Health"
		var flashbang_panel := $"../../Flashbang"
		var settings_menu := $".."
		var flashlight_label := $"../../Flashlight_label"
		var weapon_selection := $"../../Weapon Selection"
		var tooltip := $"../../Tooltip"
		var objectives := $"../../Objectives"
		var progress_bar := $"../../ProgressBar"
		information.hide()
		flashbang_panel.hide()
		flashlight_label.hide()
		weapon_selection.hide()
		tooltip.hide()
		progress_bar.hide()
		objectives.hide()
		health.hide()
		pause.show()
		settings_menu.hide()
		Engine.time_scale = 0

func _on_vsync_button_pressed():
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		GameState.vsync = false
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		GameState.vsync = true
	update_ui()

func _on_fps_button_pressed():
	if GameState.show_fps:
		GameState.show_fps = false
	else:
		GameState.show_fps = true
	update_ui()

func create_input_event(type: String, code: int) -> InputEvent:
	if type == "key":
		var ev := InputEventKey.new()
		ev.physical_keycode = code as Key
		ev.pressed = true
		return ev
	elif type == "mouse":
		var ev := InputEventMouseButton.new()
		ev.button_index = code as MouseButton
		ev.pressed = true
		return ev
	return null

func _on_reset_to_default_pressed():
	for action_name in default_bindings.keys():
		var bind = default_bindings[action_name]
		var event := create_input_event(bind[0], bind[1])
		if event:
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, event)
	update_all_buttons()
	update_ui()
	if user_interface:
		user_interface.update_weapon_selection_labels()

func _on_fps_button_2_pressed():
	if GameState.extended_fps:
		GameState.extended_fps = false
	else:
		GameState.extended_fps = true
	update_ui()

func _on_sound_effects_button_pressed():
	GameState.sfx = not GameState.sfx
	AudioServer.set_bus_mute(sfx_bus, not GameState.sfx)

func update_gamestate_key(action_name: String):
	match action_name:
		"interact":
			GameState.update_interact_key()
		"grenade":
			GameState.update_flashbang_key()
