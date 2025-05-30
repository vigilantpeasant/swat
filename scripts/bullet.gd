extends Area2D

@onready var death_particle = preload("res://scenes/blood_splash.tscn")
@onready var blood_scene = preload("res://scenes/blood_particle.tscn")
const BULLET_SPEED := 650
var bullet_range := 1000
var travelled_distance := 200
var direction : Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta): 
	position += direction * BULLET_SPEED * delta
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > bullet_range:
		queue_free()

func _on_body_entered(body):
	queue_free()

	if body is TileMapLayer:
		var hit = blood_scene.instantiate() as GPUParticles2D
		hit.modulate = Color(0.111, 0.111, 0.111)
		get_parent().add_child(hit)
		hit.global_position = global_position
		hit.global_rotation = direction.angle()
		hit.emitting = true
		Audio.play_sound("ricochet")
		return

	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(3, global_position)
		return

	if body.is_in_group("Civilian"):
		var breakable = body.get_node_or_null("Breakable")
		if breakable and breakable.has_method("take_damage"):
			if GameState.selected_weapon == "rifle":
				breakable.take_damage(10, global_position)
			else:
				breakable.take_damage(7, global_position)
		return

	if body.is_in_group("Breakable"):
		var breakable = body.get_node_or_null("Breakable")
		if breakable and breakable.has_method("take_damage"):
			if GameState.selected_weapon == "rifle":
				breakable.take_damage(2, global_position)
			else:
				breakable.take_damage(1, global_position)
		return
