extends Control

@onready var handcuffed_civilian := $"Panel/VBoxContainer/Handcuffed Civilian"
@onready var neutralized_suspect := $"Panel/VBoxContainer/Neutralized Suspect"
@onready var arrested_suspect := $"Panel/VBoxContainer/Arrested Suspect"
@onready var unauthorized_force := $"Panel/VBoxContainer/Unauthorized Force"
@onready var people_killed_by_suspects := $"Panel/VBoxContainer/People Killed By Suspects"
@onready var collected_evidences := $"Panel/VBoxContainer/Collected Evidences"
@onready var total_score_label := $"Panel/VBoxContainer/Total Score"
@onready var ranking := $Panel/VBoxContainer/Ranking

var total_score := 0
var is_challenge_extra := false

func handle_result(cause_of_endlevel : String):
	total_score = 0
	for hc in GameState.handcuffed_civilian:
		total_score += 10
	for hc in GameState.neutralized_suspect:
		total_score += 10
	for hc in GameState.arrested_suspect:
		total_score += 20
	for hc in GameState.unauthorized_force:
		total_score -= 10
	for hc in GameState.collected_evidence:
		total_score += 5
	for hc in GameState.people_killed_by_suspects:
		total_score -= 15
	if GameState.no_flashlight:
		total_score += 10
		is_challenge_extra = true
	if GameState.no_casualities:
		if GameState.unauthorized_force == 0 and GameState.people_killed_by_suspects == 0:
			total_score += 50
			is_challenge_extra = true
		else:
			total_score = 0
	
	handcuffed_civilian.text = "Handcuffed Civilians: [color=green]%s[/color]" % GameState.handcuffed_civilian
	neutralized_suspect.text = "Neutralized Suspects: [color=green]%s[/color]" % GameState.neutralized_suspect
	arrested_suspect.text = "Arrested Suspects: [color=green]%s[/color]" % GameState.arrested_suspect
	unauthorized_force.text = "Unauthorized Force: [color=red]%s[/color]" % GameState.unauthorized_force
	collected_evidences.text = "Collected Evidences: [color=green]%s[/color]" % GameState.collected_evidence
	people_killed_by_suspects.text = "People Killed By Suspects: [color=red]%s[/color]" % GameState.people_killed_by_suspects
	
	var score_color := "green"
	if total_score <= 0 or cause_of_endlevel == "Killed":
		score_color = "red"
	
	var score_text := "Total Score: [color=%s]%s[/color]" % [score_color, total_score]
	
	if GameState.no_casualities:
		if GameState.unauthorized_force == 0 and GameState.people_killed_by_suspects == 0:
			score_text += "\nNo Casualties: [color=green]+50[/color]"
		else:
			score_text += "\nNo Casualties: [color=red]Failed[/color]"
	
	if GameState.no_flashlight:
		score_text += "\nNo Flashlight: [color=green]+10[/color]"
	total_score_label.text = score_text
	
	if total_score <= 0 or cause_of_endlevel == "Killed":
		ranking.text = "Ranking: [color=red]Failure[/color]"
	elif total_score > 0:
		ranking.text = "Ranking: [color=green]Success[/color]"

func _on_back_pressed():
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_restart_pressed():
	var current_scene_path := get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene_path)
