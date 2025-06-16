extends CharacterBody2D

@onready var collision_shape_2d := $CollisionShape2D
@onready var animation_player := $AnimationPlayer
@onready var sprite_2d := $AnimatedSprite2D
@onready var wall_detector := $"Wall Detector"
@onready var area_2d := $Area2D
@onready var player := get_parent().get_parent().get_node("Player")
@onready var navigation_agent := $NavigationAgent2D
@onready var navigation_region := get_parent().get_parent().get_node("NavigationRegion2D")
@onready var warning := $Warning

const SPEED = 15
var w_collider
var personality_array := ["Calm", "Aggressive"]
var personality : String
var handcuffed := false
var is_player := false
var dead := false
var on_move := false
var checking_wall := false
var has_surrendered := false
var who_killed_me : String # Player, Suspect

func _ready():
	personality = personality_array.pick_random()
	if personality == "Calm":
		has_surrendered = true

func _process(_delta):
	if is_player and not dead and not handcuffed:
		sprite_2d.look_at(player.global_position)

func _physics_process(_delta):
	if checking_wall:
		wall_detector.look_at(player.global_position)
		wall_detector.force_raycast_update()

	w_collider = wall_detector.get_collider()
	
	if checking_wall:
		if wall_detector.is_colliding():
			if not w_collider or (w_collider.is_in_group("Door") and w_collider.is_in_group("Breakable")):
				is_player = false
			elif w_collider.name == "Player" or w_collider.is_in_group("Breakable"):
				is_player = true
				sprite_2d.look_at(player.global_position)
		else:
			is_player = false
	else:
		is_player = false
	
	if on_move and not dead and not handcuffed:
		if navigation_agent.is_target_reached():
			velocity = Vector2.ZERO
			on_move = false
			personality = "Calm"
		else:
			var direction = navigation_agent.get_next_path_position() - global_position
			velocity = direction.normalized() * SPEED
		move_and_slide()

func _on_area_2d_body_entered(_body):
	checking_wall = true

func _on_area_2d_body_exited(_body):
	checking_wall = false
	if personality == "Calm":
		is_player = false

func answer_command(command_sound : String):
	if on_move:
		velocity = Vector2.ZERO
		on_move = false
		personality = "Calm"
	
	if personality == "Calm":
		warning.hide()
		sprite_2d.frame = 0
		if not has_surrendered:
			await get_tree().create_timer(0.6).timeout
			match (command_sound):
				"drop_the_weapon":
					Audio.play_sound("dont_shoot_im_unarmed")
				"hands_in_the_air":
					Audio.play_random_sound(["im_just_civilian_i_swear", "i_didnt_do_anything", "i_just_wanna_go_home"])
				"show_me_your_hands":
					Audio.play_random_sound(["im_just_civilian_i_swear", "i_didnt_do_anything", "i_just_wanna_go_home"])
		has_surrendered = true
	elif personality == "Aggressive":
		warning.show()
		var max_distance := 400
		var random_offset := Vector2(
			randf_range(-max_distance, max_distance),
			randf_range(-max_distance, max_distance)
		)
		var target_position := global_position + random_offset
		navigation_agent.target_position = target_position
		sprite_2d.look_at(target_position)
		on_move = true

func handle_flashbang_explosion(command_sound : String):
	if personality == "Aggressive":
		personality = "Calm"
		has_surrendered = true
		answer_command(command_sound)

func react_noise():
	is_player = true
