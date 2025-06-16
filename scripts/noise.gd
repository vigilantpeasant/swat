extends Node2D

@onready var area_2d := $Area2D

func _ready():
	await get_tree().physics_frame
	var overlapping_bodies = area_2d.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("Civilian") and not body.handcuffed and not body.dead:
			body.react_noise()
		elif body.is_in_group("Suspect") and not body.handcuffed and not body.dead:
			body.react_noise()
	
	await get_tree().create_timer(0.4).timeout
	queue_free()
