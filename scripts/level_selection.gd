extends Control

func _on_map_test_1_pressed():
	get_tree().change_scene_to_file("res://scenes/test_map.tscn")

func _on_back_pressed():
	if get_tree().current_scene.name == "Main Menu":
		var panel = $"../Panel"
		panel.show()
		hide()
	else:
		hide()

func _on_flashlight_button_pressed():
	if GameState.no_flashlight:
		GameState.no_flashlight = false
	else:
		GameState.no_flashlight = true
