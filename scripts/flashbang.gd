extends RigidBody2D

@onready var point_light_2d = $PointLight2D
const DECELERATION = 900.0
var GRENADE_SPEED = 400.0
var travelled_distance := 0.0
var direction := Vector2.ZERO
var death_splash = preload("res://scenes/blood_particle.tscn")

func _ready():
	add_collision_exception_with(self)
	#direction = Vector2.RIGHT.rotated(rotation)
	linear_velocity = direction * GRENADE_SPEED
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.3
	
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(0.1).timeout
	$CollisionShape2D.set_deferred("disabled", false)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if GRENADE_SPEED > 0:
		travelled_distance += GRENADE_SPEED * state.step
		GRENADE_SPEED -= DECELERATION * state.step
		if GRENADE_SPEED < 0:
			GRENADE_SPEED = 0
		linear_velocity = direction * GRENADE_SPEED
	else:
		create_explosion()

func create_explosion():
	GRENADE_SPEED = 0
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	sleeping = true
	$Area2D.monitoring = true
	
	var explosion = death_splash.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.emitting = true
	Audio.play_sound("flashbang")
	point_light_2d.show()

	await get_tree().create_timer(0.2).timeout
	create_tween().tween_property($Area2D, "modulate", Color.TRANSPARENT, 0.5)
	$Area2D.monitoring = false
	await get_tree().create_timer(0.5).timeout
	queue_free()
