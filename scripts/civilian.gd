extends CharacterBody2D
@onready var light_occluder_2d = $LightOccluder2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $AnimatedSprite2D
@onready var area_2d = $Area2D
@onready var player = get_parent().get_parent().get_node("Player")
var handcuffed := false
var is_player := false
var dead := false
var player_in_range := false

func _process(_delta):
	if player_in_range and not dead and not handcuffed:
		look_at(player.global_position)

func _on_area_2d_body_entered(_body):
	player_in_range = true

func _on_area_2d_body_exited(_body):
	player_in_range = false
