extends Camera2D

@export var decay := 0.8
@export var max_offset := Vector2(100, 75)
@export var max_roll := 0.1
@export var follow_node : Node2D

var trauma := 0.0
var trauma_power := 1.25

func _ready():
	randomize()

func _process(delta):
	if follow_node:
		global_position = follow_node.global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount : float):
	trauma = min(max(trauma, amount), 1.0)

func reset_trauma():
	trauma = 0.0

func shake():
	var amount := pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
