extends StaticBody2D

@onready var detector := $Detector
@onready var sprite := $Sprite2D

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

func _physics_process(delta):
	var target := closed_rotation
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
