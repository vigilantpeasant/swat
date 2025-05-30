extends StaticBody2D

@onready var ray_cast_2d = get_parent().get_parent().get_node("Player/RayCast2D") as RayCast2D
@onready var marker_2d = $Marker2D
@onready var detector = $Detector
@onready var sprite = $Sprite2D
var flashbang_scene = preload("res://scenes/flashbang.tscn")
var door_is_open := false
var target_rotation := 0.0
var open_rotation := 0.0
var closed_rotation := 0.0
var rotation_speed := 2.5

func _ready():
	add_to_group("Door")
	closed_rotation = rotation
	open_rotation = closed_rotation + deg_to_rad(-90)
	door_is_open = false
	rotation = closed_rotation

func _input(_event):
	if Input.is_action_just_pressed("grenade") and ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider() == self and GameState.tooltip_mode == "door":
			var flashbang = flashbang_scene.instantiate()
			flashbang.global_position = marker_2d.global_position
			var cast_origin = ray_cast_2d.global_position
			var cast_target = ray_cast_2d.get_collision_point()
			var direction = (cast_target - cast_origin).normalized()

			flashbang.direction = direction
			get_parent().add_child(flashbang)
			Audio.play_sound("flashbang_deploy")

func _physics_process(delta):
	var target = closed_rotation
	if door_is_open:
		if detector.get_overlapping_bodies().size() > 0:
			return
		target = open_rotation

	if not is_equal_approx(rotation, target):
		rotation = move_toward(rotation, target, rotation_speed * delta)

func open_door():
	if door_is_open:
		Audio.play_sound("door")
		door_is_open = false
	else:
		if detector.get_overlapping_bodies().size() == 0:
			Audio.play_sound("door")
			door_is_open = true
