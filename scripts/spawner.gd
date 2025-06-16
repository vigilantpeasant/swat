extends Node2D

@export_enum("Thug", "Mafia") var enemy_type := "Thug"
@export_enum("Null", "Suspect", "Civilian") var who_to_spawn := "Null"
@export_enum("Null", "Calm", "Aggressive") var suspect_aggression := "Null"
@onready var placeholder = $Placeholder
var suspect_scene := preload("res://scenes/suspect.tscn")
var civilian_scene := preload("res://scenes/civilian.tscn")

var chance_of_suspect := 60.0
var chance_of_suspect_aggressive := 75.0
var weapons = ["Rifle", "SMG", "Pistol"]
var weapon_selected : String

func _ready():
	placeholder.queue_free()
	if who_to_spawn == "Suspect":
		spawn_suspect()
	elif who_to_spawn == "Suspect":
		spawn_civilian()
	elif who_to_spawn == "Null":
		var random_roll = randf_range(0.0, 100.0)
		
		if random_roll <= chance_of_suspect:
			spawn_suspect()
		else:
			spawn_civilian()

func spawn_suspect():
	var new_suspect = suspect_scene.instantiate()
	get_parent().call_deferred("add_child", new_suspect)
	new_suspect.global_position = global_position
	new_suspect.get_node("AnimatedSprite2D").play(enemy_type)
	weapon_selected = weapons[randi_range(0, weapons.size() - 1)]
	new_suspect.spawner_node = self
	
	if suspect_aggression == "Calm":
		new_suspect.personality = "Calm"
	elif suspect_aggression == "Aggressive":
		new_suspect.personality = "Aggressive"
	elif suspect_aggression == "Null":
		var aggressive_roll = randf_range(0.0, 100.0)
		if aggressive_roll <= chance_of_suspect_aggressive:
			new_suspect.personality = "Aggressive"
		else:
			new_suspect.personality = "Calm"
	
	if weapon_selected == "Rifle":
		new_suspect.sound_to_play = "rifle"
		new_suspect.rate_of_fire = new_suspect.RATE_OF_FIRE_RIFLE
	elif weapon_selected == "SMG":
		new_suspect.sound_to_play = "smg_shoot"
		new_suspect.rate_of_fire = new_suspect.RATE_OF_FIRE_SUBMACHINE
	elif weapon_selected == "Pistol":
		new_suspect.sound_to_play = "pistol"
		new_suspect.rate_of_fire = new_suspect.RATE_OF_FIRE_PISTOL

func spawn_civilian():
	var new_civilian = civilian_scene.instantiate()
	get_parent().call_deferred("add_child", new_civilian)
	new_civilian.global_position = global_position
