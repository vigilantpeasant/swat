extends Node2D

@onready var parent = get_parent()
@onready var parent_sprite = get_parent().get_node("AnimatedSprite2D")
@onready var user_interface = get_parent().get_parent().get_parent().get_node("User Interface")
@onready var ray_cast_2d = get_parent().get_parent().get_parent().get_node("Player/RayCast2D") as RayCast2D

const HANDCUFF_TIME := 1.25
var progress_time := 0.0

func _process(delta):
	if not parent.is_player:
		return
	
	if Input.is_action_pressed("interact") and ray_cast_2d.is_colliding() and not parent.dead:
		if ray_cast_2d.get_collider() == parent:
			progress_time += delta
			user_interface.progress_bar.show()
			user_interface.progress_bar.value = (progress_time / HANDCUFF_TIME) * 100
			
			if progress_time >= HANDCUFF_TIME:
				user_interface.progress_bar.hide()
				user_interface.progress_bar.value = 0
				progress_time = 0.0
				apply_handcuff()
	else:
		progress_time = max(progress_time - delta * 3, 0)
		user_interface.progress_bar.value = (progress_time / HANDCUFF_TIME) * 100
		if progress_time <= 0:
			user_interface.progress_bar.hide()

func apply_handcuff():
	parent.is_player = false
	parent.handcuffed = true
	parent.area_2d.queue_free()
	parent_sprite.frame = 1
	queue_free()
