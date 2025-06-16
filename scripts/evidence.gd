extends RigidBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
var type : String

func _ready():
	add_to_group("Evidence")
	match type:
		"Rifle":
			animated_sprite_2d.frame = 0
		"SMG":
			animated_sprite_2d.frame = 1
		"pistol":
			animated_sprite_2d.frame = 2

func collect_evidence():
	Audio.play_sound("evidence_pickup")
	GameState.collected_evidence += 1
	queue_free()
