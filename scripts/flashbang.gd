extends RigidBody2D

@onready var point_light_2d := $PointLight2D
@onready var area_2d := $Area2D
@onready var player := get_parent().get_parent()
@onready var camera_2d := player.get_node("Camera2D")
@onready var sprite := $Sprite2D
@onready var collision_shape := $CollisionShape2D
@onready var noise_scene := preload("res://scenes/noise.tscn")
@onready var death_splash := preload("res://scenes/blood_particle.tscn")

const DECELERATION = 800.0
const GRENADE_SPEED = 500.0
const TIME_TO_EXPLODE = 1.25
const EXPLOSION_FLASH_TIME = 0.2
const EXPLOSION_FADE_TIME = 0.5

var direction := Vector2.ZERO
var timer := 0.0
var has_exploded := false
var current_speed := GRENADE_SPEED

func _ready():
	add_collision_exception_with(self)
	linear_velocity = direction * current_speed
	
	collision_shape.set_deferred("disabled", true)
	await get_tree().create_timer(0.1).timeout
	collision_shape.set_deferred("disabled", false)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if has_exploded:
		return
	
	timer += state.step
	if timer >= TIME_TO_EXPLODE:
		create_explosion()
		return
	
	if current_speed > 0:
		current_speed -= DECELERATION * state.step
		if current_speed < 0:
			current_speed = 0
		linear_velocity = direction * current_speed

func create_explosion():
	camera_2d.add_trauma(0.3)
	has_exploded = true
	current_speed = 0
	sprite.visible = false
	collision_shape.set_deferred("disabled", true)
	sleeping = true
	area_2d.monitoring = true
	var explosion := death_splash.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.emitting = true
	Audio.play_sound("flashbang")
	point_light_2d.show()
	
	flashbang_explosion()

	await get_tree().create_timer(EXPLOSION_FLASH_TIME).timeout
	create_tween().tween_property(area_2d, "modulate", Color.TRANSPARENT, EXPLOSION_FADE_TIME)
	area_2d.monitoring = false
	await get_tree().create_timer(EXPLOSION_FADE_TIME).timeout
	queue_free()

func flashbang_explosion():
	var overlapping_bodies = area_2d.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("Civilian") or body.is_in_group("Suspect"):
			body.handle_flashbang_explosion(player.current_command_voiceline)
	
	var noise_hit := noise_scene.instantiate() as Node2D
	get_tree().current_scene.call_deferred("add_child", noise_hit)
	noise_hit.global_position = global_position
