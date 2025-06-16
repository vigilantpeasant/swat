extends CharacterBody2D

@onready var collision_shape_2d := $CollisionShape2D
@onready var sprite_2d := $AnimatedSprite2D
@onready var area_2d := $Area2D
@onready var player := get_parent().get_parent().get_node("Player")
@onready var animation_player := $AnimationPlayer
@onready var ray_cast_2d := $RayCast2D
@onready var wall_detector := $"Wall Detector"
@onready var marker_2d := $"AnimatedSprite2D/Marker2D"
@onready var navigation_agent := $NavigationAgent2D
@onready var warning := $Alert
var bullet_scene := preload("res://scenes/bullet.tscn")
var evidence_scene := preload("res://scenes/evidence.tscn")
var spawner_node : Node2D
var collider
var w_collider
var w_parent
var evidence

const SPEED = 70
const RATE_OF_FIRE_RIFLE := 0.4
const RATE_OF_FIRE_PISTOL := 0.5
const RATE_OF_FIRE_SUBMACHINE := 0.3
const MAX_RIFLE_AMMO := 20
const MAX_PISTOL_AMMO := 10
const MAX_SUBMACHINE_AMMO := 30
const RIFLE_RELOAD_TIME := 1.25
const PISTOL_RELOAD_TIME := 0.6
const SUBMACHINE_RELOAD_TIME := 1.3

var rate_of_fire : float
var sound_to_play : String
var sprite_to_play : int
var evidence_weapon : String
var reload_sound_to_play : String
var current_ammo : int
var max_ammo : int
var reload_time : float
var on_move := false
var personality : String
var handcuffed := false
var is_player := false
var dead := false
var can_shoot := true
var has_reacted := false
var has_evidence := true
var has_surrendered := false
var checking_wall := false
var player_detected := false
var suspect_voicelines := []
var who_killed_me : String # Player, Suspect
var reaction_time : float

func _ready():
	reaction_time = randf_range(0.5, 1.2)
	
	if spawner_node.weapon_selected == "Rifle":
		max_ammo = MAX_RIFLE_AMMO
		current_ammo = max_ammo
		reload_time = RIFLE_RELOAD_TIME
		reload_sound_to_play = "rifle_reload"
		sprite_to_play = 3
	if spawner_node.weapon_selected == "SMG":
		max_ammo = MAX_SUBMACHINE_AMMO
		current_ammo = max_ammo
		reload_time = SUBMACHINE_RELOAD_TIME
		reload_sound_to_play = "smg_reload"
		sprite_to_play = 3
	if spawner_node.weapon_selected == "Pistol":
		max_ammo = MAX_PISTOL_AMMO
		current_ammo = max_ammo
		reload_time = PISTOL_RELOAD_TIME
		reload_sound_to_play = "pistol_reload"
		sprite_to_play = 4

func _process(_delta):
	if is_player and not dead and not handcuffed:
		look_at_player()

func _physics_process(_delta):
	if dead or handcuffed or not player.is_alive:
		return
	
	if is_player:
		look_at_player()
		ray_cast_2d.force_raycast_update()
	if checking_wall:
		wall_detector.force_raycast_update()
	
	collider = ray_cast_2d.get_collider()
	w_collider = wall_detector.get_collider()
	
	if checking_wall:
		wall_detector.look_at(player.global_position)
		if not w_collider:
			return
		if wall_detector.is_colliding():
			if not w_collider:
				return
			if w_collider.name == "Player":
				is_player = true
				checking_wall = false
				look_at_player()
	
	if personality == "Calm":
		return
	
	if ray_cast_2d.is_colliding() and is_player:
		if collider.name == "Player" or collider.is_in_group("Breakable"):
			if not collider.is_in_group("Suspect"):
				player_detected = true
				if can_shoot:
					if not has_reacted:
						react_to_player()
					else:
						shoot()
			elif player_detected:
				follow_player()
		elif player_detected:
			follow_player()
	elif player_detected:
		follow_player()

func _on_area_2d_body_entered(_body):
	checking_wall = true

func _on_area_2d_body_exited(_body):
	checking_wall = false
	if personality == "Calm":
		is_player = false

func react_to_player():
	if personality == "Aggressive":
		warning.show()
	else:
		warning.hide()
	can_shoot = false
	
	await get_tree().create_timer(reaction_time).timeout
	if dead:
		return
	
	collider = ray_cast_2d.get_collider()
	if ray_cast_2d.is_colliding():
		if collider.name == "Player" or collider.is_in_group("Breakable"):
			shoot()
	has_reacted = true
	can_shoot = true

func shoot():
	if dead or handcuffed:
		return
	if current_ammo <= 0:
		reload()
		return
	
	var angle_offset := deg_to_rad(randf_range(-8.0, 8.0))
	current_ammo -= 1
	sprite_2d.frame = sprite_to_play
	can_shoot = false
	
	marker_2d.look_at(player.global_position)
	var new_bullet := bullet_scene.instantiate()
	new_bullet.modulate = Color(0.929, 0.885, 0.353)
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	new_bullet.type = "Suspect"
	new_bullet.enemy_weapon = spawner_node.weapon_selected
	marker_2d.call_deferred("add_child", new_bullet)
	
	Audio.play_sound(sound_to_play)
	await get_tree().create_timer(rate_of_fire).timeout
	can_shoot = true

func reload():
	Audio.play_sound(reload_sound_to_play)
	can_shoot = false
	await get_tree().create_timer(reload_time).timeout
	current_ammo = max_ammo
	can_shoot = true

func follow_player():
	if dead:
		return
	
	sprite_2d.frame = 3
	navigation_agent.target_position = player.global_position
	
	if navigation_agent.is_target_reached():
		velocity = Vector2.ZERO
	else:
		var next_position = navigation_agent.get_next_path_position()
		var move_direction = next_position - global_position
		velocity = move_direction.normalized() * SPEED
		
		var old_position = global_position
		move_and_slide()
		
		if (global_position - old_position).length() < 0.5:
			if can_shoot:
				var shoot_direction = move_direction.normalized()
				sprite_2d.look_at(global_position + shoot_direction)
				ray_cast_2d.look_at(global_position + shoot_direction)
				marker_2d.look_at(global_position + shoot_direction)
				shoot()

func look_at_player():
	sprite_2d.look_at(player.global_position)
	ray_cast_2d.look_at(player.global_position)

func answer_command(command_sound : String):
	if personality == "Aggressive":
		warning.show()
		is_player = true
	elif personality == "Calm":
		if not evidence and has_evidence:
			spawn_evidence()
		if not handcuffed:
			sprite_2d.frame = 0
			warning.hide()
		if not has_surrendered:
			await get_tree().create_timer(0.6).timeout
			match (command_sound):
				"drop_the_weapon":
					Audio.play_random_sound(["alright_dont_shoot_i_give_up", "k_im_dropping_the_weapon"])
				"hands_in_the_air":
					Audio.play_random_sound(["alright_dont_shoot_i_give_up", "kk_you_got_me", "i_dont_want_any_trouble"])
				"show_me_your_hands":
					Audio.play_random_sound(["alright_dont_shoot_i_give_up", "kk_you_got_me"])
		has_surrendered = true

func handle_flashbang_explosion(command_sound : String):
	personality = "Calm"
	has_surrendered = true
	answer_command(command_sound)
	spawn_evidence()

func spawn_evidence():
	if not has_evidence:
		return
	
	has_evidence = false
	evidence = evidence_scene.instantiate()
	evidence.global_position = marker_2d.global_position
	marker_2d.call_deferred("add_child", evidence)
	evidence.type = spawner_node.weapon_selected

func react_noise():
	is_player = true
	look_at_player()
