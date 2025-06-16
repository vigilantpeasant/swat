extends Node2D

@export_enum("Glass", "Wood", "Human", "Player", "Metal") var type: String
@export var health : int
@export var color : Color
@onready var parent := get_parent()
@onready var death_particle := preload("res://scenes/blood_splash.tscn")
@onready var blood_scene := preload("res://scenes/blood_particle.tscn")
@onready var noise_scene := preload("res://scenes/noise.tscn")

var sound_map := {
	"Metal": "metal_hit",
	"Glass": "broken_glass",
	"Wood": "broken_door",
	"Human": "human_death",
	"Player": "human_death"
	}

func _ready():
	parent.add_to_group("Breakable")

func take_damage(damage : int, hit_position : Vector2):
	var direction := global_position.normalized()
	health -= damage
	if health <= 0:
		var hit := death_particle.instantiate() as GPUParticles2D
		get_tree().current_scene.add_child(hit)
		hit.modulate = color
		hit.global_position = hit_position
		hit.global_rotation = direction.angle()
		hit.emitting = true
		Audio.play_sound(sound_map[type])
		
		var noise_death := noise_scene.instantiate() as Node2D
		get_tree().current_scene.call_deferred("add_child", noise_death)
		noise_death.global_position = hit_position
		
		match (type):
			"Glass", "Wood", "Metal":
				parent.queue_free()
				return
			"Human":
				if parent.is_in_group("Suspect"):
					parent.spawn_evidence()
				parent.dead = true
				parent.sprite_2d.frame = 2 # Dead
				parent.scale = Vector2(1.6, 1.6)
				
				if parent.collision_shape_2d:
					parent.collision_shape_2d.queue_free()
				if parent.warning:
					parent.warning.queue_free()
				if parent.area_2d:
					parent.area_2d.queue_free()
				if parent.wall_detector:
					parent.wall_detector.queue_free()
				
				parent.set_physics_process(false)
				parent.set_process(false)
				return
			"Player":
				parent.camera_2d.add_trauma(0.12)
				parent.is_alive = false
				parent.scale = Vector2(1.6, 1.6)
				await get_tree().create_timer(0.01).timeout
				if parent.collision_shape_2d:
					parent.collision_shape_2d.queue_free()
				if parent.light_occluder_2d:
					parent.light_occluder_2d.queue_free()
				parent.animated_sprite_2d.frame = 3 # Dead
				parent.z_index = 0
				parent.set_process(false)
				await get_tree().create_timer(2.5).timeout
				parent.handle_death()
				return
	var blood := blood_scene.instantiate() as GPUParticles2D
	get_tree().current_scene.add_child(blood)
	blood.modulate = color
	blood.global_position = hit_position
	blood.global_rotation = direction.angle()
	blood.emitting = true
	
	var noise_hit := noise_scene.instantiate() as Node2D
	get_tree().current_scene.call_deferred("add_child", noise_hit)
	noise_hit.global_position = hit_position
	
	match (type):
		"Metal":
			Audio.play_sound("metal_hit")
		"Glass":
			Audio.play_sound("glass_shatter")
		"Wood":
			Audio.play_sound("door_hit")
		"Human":
			Audio.play_random_sound(["human_pain", "grunt"])
			if parent.animation_player:
				parent.animation_player.play("flash")
			parent.is_player = true
			if parent.is_in_group("Suspect"):
				parent.look_at_player()
		"Player":
			parent.camera_2d.add_trauma(0.1)
			Audio.play_random_sound(["human_pain", "grunt"])
