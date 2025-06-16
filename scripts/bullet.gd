extends Area2D

@onready var death_particle := preload("res://scenes/blood_splash.tscn")
@onready var blood_scene := preload("res://scenes/blood_particle.tscn")
@onready var noise_scene := preload("res://scenes/noise.tscn")

const BULLET_SPEED := 750
var bullet_range := 1000
var travelled_distance := 200
var direction : Vector2
var type : String # Player, Suspect
var enemy_weapon : String

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta): 
	global_position += direction * BULLET_SPEED * delta
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > bullet_range:
		queue_free()

func _on_body_entered(body):
	queue_free()
	
	if body is TileMapLayer:
		var hit := blood_scene.instantiate() as GPUParticles2D
		hit.modulate = Color(0.111, 0.111, 0.111)
		get_parent().add_child(hit)
		hit.global_position = global_position
		hit.global_rotation = direction.angle()
		hit.emitting = true
		Audio.play_sound("ricochet")
		
		var noise_hit := noise_scene.instantiate() as Node2D
		get_tree().current_scene.call_deferred("add_child", noise_hit)
		noise_hit.global_position = hit.global_position
		
		return
	
	if body is Player:
		var breakable = body.get_node_or_null("Breakable")
		if enemy_weapon == "Rifle":
			breakable.take_damage(8, global_position)
		elif enemy_weapon == "SMG":
			breakable.take_damage(6, global_position)
		elif enemy_weapon == "Pistol":
			breakable.take_damage(5, global_position)
		return
	
	if body.is_in_group("Civilian"):
		var breakable = body.get_node_or_null("Breakable")
		body.who_killed_me = type
		
		if GameState.selected_weapon == "rifle":
			breakable.take_damage(10, global_position)
		elif GameState.selected_weapon == "pistol":
			breakable.take_damage(8, global_position)
		elif GameState.selected_weapon == "submachine":
			breakable.take_damage(7, global_position)
		return
	
	if body.is_in_group("Suspect"):
		if type == "Suspect":
			return
		
		var breakable = body.get_node_or_null("Breakable")
		body.who_killed_me = type
		
		if GameState.selected_weapon == "rifle":
			breakable.take_damage(8, global_position)
		elif GameState.selected_weapon == "pistol":
			breakable.take_damage(6, global_position)
		elif GameState.selected_weapon == "submachine":
			breakable.take_damage(5, global_position)
		return
	
	if body.is_in_group("Breakable"):
		var breakable = body.get_node_or_null("Breakable")
		breakable.take_damage(2, global_position)
		
		return
