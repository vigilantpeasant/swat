extends CharacterBody2D
class_name Player

@onready var collision_shape_2d := $CollisionShape2D
@onready var light_occluder_2d := $LightOccluder2D
@onready var breakable := $Breakable
@onready var camera_2d := $Camera2D
@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var user_interface := get_parent().get_node("User Interface")
@onready var ammo := user_interface.get_node("CanvasLayer/Information/Ammo")
@onready var flashlight_label := user_interface.get_node("CanvasLayer/Flashlight_label")
@onready var weapon_panel := user_interface.get_node("CanvasLayer/Weapon Selection/Panel")
@onready var marker_2d := $Marker2D
@onready var flashlight := $Flashlight
@onready var self_light := $"Self Light"
@onready var ray_cast_2d := $RayCast2D
@onready var flashbang_cast := $"Flashbang Cast"
@onready var command_zone := $"Command Zone"
var bullet_scene := preload("res://scenes/bullet.tscn")
var flashbang_scene := preload("res://scenes/flashbang.tscn")

const SPEED := 250
const ACCELERATION := 850
const FRICTION := 550
const RATE_OF_FIRE_RIFLE := 0.25
const RATE_OF_FIRE_PISTOL := 0.35
const RATE_OF_FIRE_SUBMACHINE := 0.15
const GRENADE_INTERVAL := 2.0
const MISS_CHANCE := 0.25
const MAX_MISS_ANGLE := 4.0
const MAX_RIFLE_AMMO := 20
const MAX_PISTOL_AMMO := 10
const MAX_SUBMACHINE_AMMO := 30
const RIFLE_RELOAD_TIME := 1.25
const PISTOL_RELOAD_TIME := 0.6
const SUBMACHINE_RELOAD_TIME := 1.3
const COMMAND_COOLDOWN_TIME := 1.5

var direction : Vector2
var max_health := 100
var flashbang_count := 3
var current_rifle_ammo := MAX_RIFLE_AMMO
var current_pistol_ammo := MAX_PISTOL_AMMO
var current_submachine_ammo := MAX_SUBMACHINE_AMMO
var can_shoot := true
var is_reloading := false
var can_throw_grenade := true
var max_total_rifle_ammo := 30
var max_total_pistol_ammo := 20
var max_total_submachine_ammo := 60
var total_rifle_ammo := max_total_rifle_ammo
var total_pistol_ammo := max_total_pistol_ammo
var total_submachine_ammo := max_total_submachine_ammo
var flashlight_on := true
var is_alive := true
var is_moving := false
var command_voicelines := ["drop_the_weapon", "hands_in_the_air", "show_me_your_hands"]
var current_command_voiceline : String
var is_sound_playing := false
var can_command := true

func _ready():
	breakable.health = max_health
	flashbang_count = GameState.flashbang_count
	if GameState.no_flashlight:
		enable_flashlight(false)
	
	update_ammo_text()    
	weapon_selection_on_ready()

func _physics_process(delta):
	if not is_alive or Engine.time_scale == 0:
		return
	
	look_at(get_global_mouse_position())
	direction = Input.get_vector("left", "right", "up", "down")
	is_moving = direction.length() > 0
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()

func _process(_delta):
	if not is_alive or Engine.time_scale == 0:
		return
	if not is_sound_playing and is_moving:
		Audio.play_sound("walk")
		is_sound_playing = true
		await get_tree().create_timer(0.65).timeout
		is_sound_playing = false
	update_interaction_tooltip()
	handle_actions()

func _input(_event):
	if not is_alive or Engine.time_scale == 0:
		return
	weapon_selection()

func handle_actions():
	if Input.is_action_just_pressed("flashlight") and not GameState.no_flashlight:
		enable_flashlight(true)
	
	if Input.is_action_pressed("attack") and can_shoot:
		shoot()
	
	if Input.is_action_just_pressed("command") and can_command:
		command_suspect()
	
	if Input.is_action_just_pressed("grenade") and can_throw_grenade:
		if flashbang_cast.is_colliding() and flashbang_cast.get_collider() is TileMapLayer:
			return
		throw_grenade()
	
	if Input.is_action_just_pressed("reload") and not is_reloading:
		if (GameState.selected_weapon == "rifle" and current_rifle_ammo < MAX_RIFLE_AMMO and total_rifle_ammo > 0) or \
		   (GameState.selected_weapon == "pistol" and current_pistol_ammo < MAX_PISTOL_AMMO and total_pistol_ammo > 0) or \
		   (GameState.selected_weapon == "submachine" and current_submachine_ammo < MAX_SUBMACHINE_AMMO and total_submachine_ammo > 0):
			is_reloading = true
			can_shoot = false
			ammo.text = "Reload"
			reload()
	
	if Input.is_action_just_pressed("interact"):
		var interactable := get_pointed_interactable()
		if interactable.node:
			if interactable.type == "door":
				interactable.node.call("open_door")
			if interactable.type == "evidence" and not is_reloading:
				interactable.node.call("collect_evidence")

	if is_reloading:
		if GameState.selected_weapon == "rifle":
			animated_sprite_2d.frame = 0
		elif GameState.selected_weapon == "pistol":
			animated_sprite_2d.frame = 1
		elif GameState.selected_weapon == "submachine":
			animated_sprite_2d.frame = 2

func weapon_selection_on_ready():
	if GameState.selected_weapon == "rifle" or GameState.selected_weapon == "submachine":
		weapon_panel.position = Vector2(-80, -112)
		if GameState.selected_weapon == "rifle":
			animated_sprite_2d.frame = 0
		else: # submachine
			animated_sprite_2d.frame = 2
	elif GameState.selected_weapon == "pistol":
		weapon_panel.position = Vector2(-80, -150)
		animated_sprite_2d.frame = 1

func weapon_selection():
	if Input.is_action_just_pressed("key1") and not is_reloading:
		GameState.selected_weapon = GameState.initial_primary_weapon
		user_interface.reset_ws_timer()
		weapon_panel.position = Vector2(-80, -112)
		if GameState.selected_weapon == "rifle":
			Audio.play_sound("rifle_switch")
		elif GameState.selected_weapon == "submachine":
			Audio.play_sound("smg_switch")
		update_ammo_text()
	
	if Input.is_action_just_pressed("key2") and not is_reloading:
		GameState.selected_weapon = "pistol"
		user_interface.reset_ws_timer()
		weapon_panel.position = Vector2(-80, -150)
		Audio.play_sound("pistol_switch")
		update_ammo_text()
	
	if GameState.selected_weapon == "rifle":
		animated_sprite_2d.frame = 0
	elif GameState.selected_weapon == "pistol":
		animated_sprite_2d.frame = 1
	elif GameState.selected_weapon == "submachine":
		animated_sprite_2d.frame = 2

func update_ammo_text():
	if GameState.selected_weapon == "rifle":
		ammo.text = str(current_rifle_ammo) + " / " + str(total_rifle_ammo)
	elif GameState.selected_weapon == "pistol":
		ammo.text = str(current_pistol_ammo) + " / " + str(total_pistol_ammo)
	elif GameState.selected_weapon == "submachine":
		ammo.text = str(current_submachine_ammo) + " / " + str(total_submachine_ammo)

func shoot():
	var current_ammo := 0
	@warning_ignore("unused_variable")
	var max_ammo := 0
	var rate_of_fire := 0.0
	var sound_to_play := ""
	var weapon_type := GameState.selected_weapon
	var trauma := 0.0
	
	if weapon_type == "rifle":
		current_ammo = current_rifle_ammo
		max_ammo = MAX_RIFLE_AMMO
		rate_of_fire = RATE_OF_FIRE_RIFLE
		sound_to_play = "rifle"
		trauma = 0.13
	elif weapon_type == "pistol":
		current_ammo = current_pistol_ammo
		max_ammo = MAX_PISTOL_AMMO
		rate_of_fire = RATE_OF_FIRE_PISTOL
		sound_to_play = "silenced_pistol"
		trauma = 0.1
	elif weapon_type == "submachine":
		current_ammo = current_submachine_ammo
		max_ammo = MAX_SUBMACHINE_AMMO
		rate_of_fire = RATE_OF_FIRE_SUBMACHINE
		sound_to_play = "smg_shoot"
		trauma = 0.115
	
	if current_ammo <= 0 or is_reloading or not is_alive or Engine.time_scale == 0:
		return
	
	can_shoot = false
	
	if weapon_type == "rifle":
		current_rifle_ammo -= 1
	elif weapon_type == "pistol":
		current_pistol_ammo -= 1
	elif weapon_type == "submachine":
		current_submachine_ammo -= 1
	
	update_ammo_text()
	
	var angle_offset := deg_to_rad(randf_range(-MAX_MISS_ANGLE, MAX_MISS_ANGLE))
	
	var new_bullet = bullet_scene.instantiate()
	new_bullet.modulate = Color(0.929, 0.885, 0.353)
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	new_bullet.type = "Player"
	marker_2d.add_child(new_bullet)
	
	Audio.play_sound(sound_to_play)
	camera_2d.add_trauma(trauma)
	await get_tree().create_timer(rate_of_fire).timeout
	can_shoot = true

func throw_grenade():
	if not is_alive:
		return
	if flashbang_count <= 0:
		return
	flashbang_count -= 1
	can_throw_grenade = false
	var flashbang := flashbang_scene.instantiate()
	flashbang.global_position = marker_2d.global_position
	flashbang.global_rotation = marker_2d.global_rotation
	flashbang.direction = Vector2.RIGHT.rotated(rotation)
	marker_2d.add_child(flashbang)
	Audio.play_sound("flashbang_deploy")
	await get_tree().create_timer(GRENADE_INTERVAL).timeout
	can_throw_grenade = true

func command_suspect():
	can_command = false
	current_command_voiceline = command_voicelines.pick_random()
	Audio.play_sound(current_command_voiceline)
	
	var overlapping_bodies = command_zone.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("Civilian") and not body.handcuffed and not body.dead:
			body.answer_command(current_command_voiceline)
		elif body.is_in_group("Suspect") and not body.handcuffed and not body.dead:
			body.answer_command(current_command_voiceline)
			
	await get_tree().create_timer(COMMAND_COOLDOWN_TIME).timeout
	can_command = true

func enable_flashlight(action : bool):
	flashlight_on = !flashlight_on
	if action:
		Audio.play_sound("turn")
	
	if flashlight_on:
		flashlight.show()
		self_light.hide()
		flashlight_label.text = "Flashlight On"
	else:
		flashlight.hide()
		self_light.show()
		flashlight_label.text = ""

func reload():
	var reload_time : float
	if GameState.selected_weapon == "rifle":
		var ammo_needed = MAX_RIFLE_AMMO - current_rifle_ammo
		var ammo_to_reload = min(ammo_needed, total_rifle_ammo)
		current_rifle_ammo += ammo_to_reload
		total_rifle_ammo -= ammo_to_reload
		Audio.play_sound("rifle_reload")
		reload_time = RIFLE_RELOAD_TIME
	elif GameState.selected_weapon == "pistol":
		var ammo_needed = MAX_PISTOL_AMMO - current_pistol_ammo
		var ammo_to_reload = min(ammo_needed, total_pistol_ammo)
		current_pistol_ammo += ammo_to_reload
		total_pistol_ammo -= ammo_to_reload
		Audio.play_sound("pistol_reload")
		reload_time = PISTOL_RELOAD_TIME
	elif GameState.selected_weapon == "submachine":
		var ammo_needed = MAX_SUBMACHINE_AMMO - current_submachine_ammo
		var ammo_to_reload = min(ammo_needed, total_submachine_ammo)
		current_submachine_ammo += ammo_to_reload
		total_submachine_ammo -= ammo_to_reload
		Audio.play_sound("smg_reload")
		reload_time = SUBMACHINE_RELOAD_TIME
	
	await get_tree().create_timer(reload_time).timeout
	update_ammo_text()
	is_reloading = false
	can_shoot = true

func get_pointed_interactable() -> Dictionary:
	if not ray_cast_2d.is_colliding():
		return { "node": null, "type": "" }
	
	var collider = ray_cast_2d.get_collider()
	if collider == null:
		return { "node": null, "type": "" }
	
	if collider.is_in_group("Civilian"):
		if collider.dead or collider.handcuffed or collider.on_move:
			return { "node": null, "type": "" }
		return { "node": collider, "type": "civilian" }
	
	if collider.is_in_group("Suspect"):
		if collider.dead or collider.handcuffed or collider.on_move:
			return { "node": null, "type": "" }
		return { "node": collider, "type": "suspect" }
	
	if collider.is_in_group("Door"):
		return { "node": collider, "type": "door" }
	
	if collider.is_in_group("Evidence"):
		return { "node": collider, "type": "evidence" }
	
	return { "node": null, "type": "" }

func update_interaction_tooltip():
	var interactable := get_pointed_interactable()
	
	if interactable.node:
		if interactable.type == "civilian" and interactable.node.personality == "Calm":
			var civilian = interactable.node
			if not civilian.has_node("Handcuff"):
				return
			GameState.tooltip_mode = "handcuff"
			user_interface.tooltip.text = "[%s] Handcuff" % GameState.interact_key
			civilian.is_player = true
		
		elif interactable.type == "suspect" and interactable.node.personality == "Calm" and not interactable.node.has_evidence:
			var suspect = interactable.node
			if not suspect.has_node("Handcuff"):
				return
			GameState.tooltip_mode = "handcuff"
			user_interface.tooltip.text = "[%s] Handcuff" % GameState.interact_key
			suspect.is_player = true
		
		elif interactable.type == "door":
			var door = interactable.node
			var door_text := "Open"
			if door.door_is_open:
				door_text = "Close"
			
			GameState.tooltip_mode = "door"
			
			var show_flashbang_text := false
			if flashbang_cast.is_colliding():
				var flashbang_collider = flashbang_cast.get_collider()
				if flashbang_collider == door:
					show_flashbang_text = true
			
			if show_flashbang_text:
				user_interface.tooltip.text = "[%s] %s Door\n[%s] Throw Flashbang" % [GameState.interact_key, door_text, GameState.flashbang_key]
			else:
				user_interface.tooltip.text = "[%s] %s Door" % [GameState.interact_key, door_text]
		
		elif interactable.type == "evidence":
			GameState.tooltip_mode = "evidence"
			user_interface.tooltip.text = "[%s] Collect Evidence" % GameState.interact_key
	else:
		GameState.tooltip_mode = ""
		user_interface.tooltip.text = ""
		user_interface.progress_bar.hide()

func handle_death():
	user_interface.handle_end_level("Killed")
