extends Control
@onready var flashlight_button := $TabContainer2/Settings/GridContainer/Flashlight_button
@onready var no_casualities_button = $TabContainer2/Settings/GridContainer/NoCasualities_button
@onready var flashbang_option := $TabContainer2/Settings/GridContainer2/Flashbang_option
@onready var rifle_button = $TabContainer2/Settings/GridContainer2/Rifle_button
@onready var submachine_button = $TabContainer2/Settings/GridContainer2/Submachine_button
var flashbang_index : int

func _ready():
	flashlight_button.button_pressed = GameState.no_flashlight
	no_casualities_button.button_pressed = GameState.no_casualities
	rifle_button.button_pressed = false
	submachine_button.button_pressed = false
	match (GameState.flashbang_count):
		1:
			flashbang_index = 0
		3:
			flashbang_index = 1
		5:
			flashbang_index = 2
	if GameState.selected_weapon == "rifle":
		rifle_button.button_pressed = true
	elif GameState.selected_weapon == "submachine":
		submachine_button.button_pressed = true
	flashbang_option.selected = flashbang_index

func _on_map_warehouse_pressed():
	get_tree().change_scene_to_file("res://scenes/warehouse.tscn")

func _on_back_pressed():
	if get_tree().current_scene.name == "Main Menu":
		var panel := $"../Panel"
		panel.show()
		hide()
	else:
		hide()

func _on_flashlight_button_pressed():
	if GameState.no_flashlight:
		GameState.no_flashlight = false
	else:
		GameState.no_flashlight = true

func _on_no_casualities_button_pressed():
	if GameState.no_casualities:
		GameState.no_casualities = false
	else:
		GameState.no_casualities = true

func _on_flashbang_option_item_selected(index):
	match (index):
		0:
			GameState.flashbang_count = 1
		1:
			GameState.flashbang_count = 3
		2:
			GameState.flashbang_count = 5

func _on_rifle_button_pressed():
	if rifle_button.button_pressed:
		GameState.selected_weapon = "rifle"
		GameState.initial_primary_weapon = "rifle"

func _on_submachine_button_pressed():
	if submachine_button.button_pressed:
		GameState.selected_weapon = "submachine"
		GameState.initial_primary_weapon = "submachine"
