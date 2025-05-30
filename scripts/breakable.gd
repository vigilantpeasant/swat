extends Node2D

@onready var parent = get_parent()
@onready var death_particle = preload("res://scenes/blood_splash.tscn")
@onready var blood_scene = preload("res://scenes/blood_particle.tscn")
@export_enum("Window", "Human", "Door") var type: String
@export var health : int
@export var color : Color
var sound_map := {
	"Window": "broken_glass",
	"Door": "broken_door",
	"Human": "human_death",
	}

func _ready():
	parent.add_to_group("Breakable")

func take_damage(damage : int, hit_position : Vector2):
	var direction = global_position.normalized()
	health -= damage
	if health <= 0:
		var hit = death_particle.instantiate() as GPUParticles2D
		get_tree().current_scene.add_child(hit)
		hit.modulate = color
		hit.global_position = hit_position
		hit.global_rotation = direction.angle()
		hit.emitting = true
		Audio.play_sound(sound_map[type])
		
		match (type):
			"Window", "Door":
				parent.queue_free()
				return
			"Human":
				parent.dead = true
				parent.sprite_2d.frame = 2
				parent.scale = Vector2(1.6, 1.6)
				await get_tree().create_timer(0.01).timeout
				parent.collision_shape_2d.queue_free()
				if parent.area_2d:
					parent.area_2d.queue_free()
				parent.light_occluder_2d.queue_free()
				parent.set_process(false)
				return
	var blood = blood_scene.instantiate() as GPUParticles2D
	get_tree().current_scene.add_child(blood)
	blood.modulate = color
	blood.global_position = hit_position
	blood.global_rotation = direction.angle()
	blood.emitting = true
	
	match (type):
			"Window":
				Audio.play_sound("glass_shatter")
			"Door":
				Audio.play_sound("broken_door")
			"Human":
				Audio.play_sound("human_pain")
				parent.look_at(parent.player.global_position)
