extends CharacterBody2D

@onready var camera_2d = $Camera2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var user_interface = get_parent().get_node("User Interface")
@onready var ammo = user_interface.get_node("CanvasLayer/Information/Ammo")
@onready var flashlight_label = user_interface.get_node("CanvasLayer/Flashlight_label")
@onready var marker_2d = $Marker2D
@onready var flashlight = $Flashlight
@onready var self_light = $"Self Light"
@onready var ray_cast_2d = $RayCast2D
var bullet_scene = preload("res://scenes/bullet.tscn")
var flashbang_scene = preload("res://scenes/flashbang.tscn")

const SPEED := 250
const ACCELERATION := 850
const FRICTION := 550
const RATE_OF_FIRE_RIFLE := 0.25
const RATE_OF_FIRE_PISTOL := 0.35
const GRENADE_INTERVAL := 2.0
const MISS_CHANCE := 0.3
const MAX_MISS_ANGLE := 5.0
const MAX_RIFLE_AMMO := 20
const MAX_PISTOL_AMMO := 10
const RIFLE_RELOAD_TIME := 1.25
const PISTOL_RELOAD_TIME := 0.6

var direction : Vector2
var health := 100
var max_health := 100
var current_rifle_ammo = MAX_RIFLE_AMMO
var current_pistol_ammo = MAX_PISTOL_AMMO
var can_shoot := true
var is_reloading := false
var can_throw_grenade := true
var max_total_rifle_ammo := 20
var max_total_pistol_ammo := 10
var total_rifle_ammo = max_total_rifle_ammo
var total_pistol_ammo = max_total_pistol_ammo
var flashlight_on := true
var is_alive := true
var is_moving := false

func _ready():
	if GameState.no_flashlight:
		enable_flashlight(false)

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
	update_interaction_tooltip()
	handle_actions()

func _input(_event):
	weapon_selection()

func handle_actions():
	if Input.is_action_just_pressed("flashlight") and not GameState.no_flashlight:
		enable_flashlight(true)
	
	if Input.is_action_pressed("attack") and can_shoot:
		shoot()
	
	if Input.is_action_just_pressed("quicknode") and can_throw_grenade:
		throw_grenade()
	
	if Input.is_action_just_pressed("reload") and not is_reloading:
		if (GameState.selected_weapon == "rifle" and current_rifle_ammo < MAX_RIFLE_AMMO and total_rifle_ammo > 0) or (GameState.selected_weapon == "pistol" and current_pistol_ammo < MAX_PISTOL_AMMO and total_pistol_ammo > 0):
			is_reloading = true
			can_shoot = false
			ammo.text = "Reload"
			increment_reload_bar()
	
	if Input.is_action_just_pressed("interact"):
		var interactable = get_closest_interactable()
		if interactable.node:
			if interactable.type == "door":
				interactable.node.call("open_door")
				return
	
	if is_reloading:
		if GameState.selected_weapon == "rifle":
			animated_sprite_2d.frame = 0
		elif GameState.selected_weapon == "pistol":
			animated_sprite_2d.frame = 1

func weapon_selection():
	if Input.is_action_just_pressed("key1") and not is_reloading:
		GameState.selected_weapon = "rifle"
		Audio.play_sound("rifle_switch")
		update_ammo_text()
	if Input.is_action_just_pressed("key2") and not is_reloading:
		GameState.selected_weapon = "pistol"
		Audio.play_sound("pistol_switch")
		update_ammo_text()
	
	if GameState.selected_weapon == "rifle":
		animated_sprite_2d.frame = 0
	elif GameState.selected_weapon == "pistol":
		animated_sprite_2d.frame = 1

func update_ammo_text():
	if GameState.selected_weapon == "rifle":
		ammo.text = str(current_rifle_ammo) + " / " + str(total_rifle_ammo)
	elif GameState.selected_weapon == "pistol":
		ammo.text = str(current_pistol_ammo) + " / " + str(total_pistol_ammo)

func shoot():
	if (GameState.selected_weapon == "rifle" and current_rifle_ammo <= 0) or (GameState.selected_weapon == "pistol" and current_pistol_ammo <= 0) or is_reloading or not is_alive or Engine.time_scale == 0:
		return
	
	can_shoot = false
	if GameState.selected_weapon == "rifle":
		current_rifle_ammo -= 1
		update_ammo_text()
	elif GameState.selected_weapon == "pistol":
		current_pistol_ammo -= 1
		update_ammo_text()
	
	var miss_chance = MISS_CHANCE
	if is_moving:
		miss_chance = MISS_CHANCE
	else:
		miss_chance = 0.0

	var angle_offset = 0.0
	if randf() < miss_chance:
		angle_offset = deg_to_rad(randf_range(-MAX_MISS_ANGLE, MAX_MISS_ANGLE))
	var new_bullet = bullet_scene.instantiate()
	new_bullet.modulate = Color(0.929, 0.885, 0.353)
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	marker_2d.add_child(new_bullet)
	
	var rate_of_fire
	if GameState.selected_weapon == "rifle":
		rate_of_fire = RATE_OF_FIRE_RIFLE
		Audio.play_sound("rifle")
	elif GameState.selected_weapon == "pistol":
		rate_of_fire = RATE_OF_FIRE_PISTOL
		Audio.play_sound("silenced_pistol")
	
	await get_tree().create_timer(rate_of_fire).timeout
	can_shoot = true

func throw_grenade():
	if not is_alive:
		return
	can_throw_grenade = false
	var flashbang = flashbang_scene.instantiate()
	flashbang.global_position = marker_2d.global_position
	flashbang.global_rotation = marker_2d.global_rotation
	flashbang.direction = Vector2.RIGHT.rotated(rotation)
	marker_2d.add_child(flashbang)
	Audio.play_sound("flashbang_deploy")
	await get_tree().create_timer(GRENADE_INTERVAL).timeout
	can_throw_grenade = true

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

func increment_reload_bar():
	var reload_time
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
	
	await get_tree().create_timer(reload_time).timeout
	update_ammo_text()
	is_reloading = false
	can_shoot = true

func get_closest_interactable() -> Dictionary:
	var mouse_position = get_global_mouse_position()
	var best = { "node": null, "type": "", "distance": INF }

	var interact_range = 115.0
	var facing_threshold = 0.7
	var interactable_direction = global_position.direction_to(mouse_position).normalized()

	for civilian in get_tree().get_nodes_in_group("Civilian"):
		if civilian.handcuffed:
			continue
		if civilian.dead:
			continue
		var to_civilian = (civilian.global_position - global_position).normalized()
		var dot = to_civilian.dot(interactable_direction)
		var dist = global_position.distance_to(civilian.global_position)
		if dist < interact_range and dot > facing_threshold and dist < best.distance:
			best = { "node": civilian, "type": "civilian", "distance": dist }

	for door in get_tree().get_nodes_in_group("Door"):
		var to_door = (door.global_position - global_position).normalized()
		var dot = to_door.dot(interactable_direction)
		var dist = global_position.distance_to(door.global_position)
		if dist < interact_range and dot > facing_threshold and dist < best.distance:
			best = { "node": door, "type": "door", "distance": dist }

	return best

func update_interaction_tooltip():
	var interactable = get_closest_interactable()
	
	for civilian in get_tree().get_nodes_in_group("Civilian"):
		if civilian.dead or civilian.handcuffed:
			continue
		civilian.is_player = false
	
	if interactable.node:
		if interactable.type == "civilian":
			var civilian = interactable.node
			if civilian.handcuffed or civilian.dead:
				return
			if not civilian.has_node("Handcuff"):
				return
			GameState.tooltip_mode = "handcuff"
			user_interface.tooltip.text = "[%s] Handcuff" % GameState.interact_key
			civilian.is_player = true
		elif interactable.type == "door":
			GameState.tooltip_mode = "door"
			var door = interactable.node
			var door_text = "Open"
			if door.door_is_open:
				door_text = "Close"
			user_interface.tooltip.text = "[%s] %s Door \n [%s] Throw Flashbang" % [GameState.interact_key, door_text, GameState.flashbang_key]
	else:
		GameState.tooltip_mode = ""
		user_interface.tooltip.text = ""
		user_interface.progress_bar.hide()
