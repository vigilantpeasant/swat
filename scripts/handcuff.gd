extends Node2D

@onready var parent := get_parent()
@onready var parent_sprite := get_parent().get_node("AnimatedSprite2D")
@onready var user_interface := get_parent().get_parent().get_parent().get_node("User Interface")
@onready var ray_cast_2d := get_parent().get_parent().get_parent().get_node("Player/RayCast2D") as RayCast2D

const HANDCUFF_TIME := 1.3
var progress_time := 0.0
var is_sound_playing := false

func _process(delta):
	if not parent.is_player:
		return
	
	if Input.is_action_pressed("interact") and ray_cast_2d.is_colliding() and not parent.dead and parent.has_surrendered and ray_cast_2d.get_collider() == parent:
		if not is_sound_playing:
			Audio.play_sound("handcuffing")
			is_sound_playing = true
		progress_time += delta
		user_interface.progress_bar.show()
		user_interface.progress_bar.value = (progress_time / HANDCUFF_TIME) * 100
		
		if progress_time >= HANDCUFF_TIME:
			apply_handcuff()
			Audio.stop("handcuffing")
			is_sound_playing = false
	else:
		if is_sound_playing:
			Audio.stop("handcuffing")
			is_sound_playing = false
		
		if progress_time > 0:
			progress_time = max(progress_time - delta * 3, 0)
			user_interface.progress_bar.value = (progress_time / HANDCUFF_TIME) * 100
			
			if progress_time <= 0:
				user_interface.progress_bar.hide()
				user_interface.progress_bar.value = 0

func apply_handcuff():
	Audio.play_sound("handcuffed")
	user_interface.progress_bar.hide()
	user_interface.progress_bar.value = 0
	progress_time = 0.0
	parent.is_player = false
	parent.handcuffed = true
	parent_sprite.frame = 1
	
	if parent.warning:
		parent.warning.queue_free()
	if parent.area_2d:
		parent.area_2d.queue_free()
	if parent.wall_detector:
		parent.wall_detector.queue_free()
	
	parent.set_physics_process(false)
	parent.set_process(false)
	queue_free()
