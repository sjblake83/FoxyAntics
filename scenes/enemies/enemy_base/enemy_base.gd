class_name  EnemyBase
extends CharacterBody2D

const EXPLOSION = preload("uid://dqtieift6vkhn")

@export var gravity: float = 690.0
@export var speed: float = 30.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $WallRay
@onready var floor_ray: RayCast2D = $FloorRay
@onready var hit_area: Area2D = $HitArea
@onready var hit_sound: AudioStreamPlayer2D = $HitSound


var _direction: int = -1
var _hit: bool = false
var _die_on_sound: bool = false

func _ready() -> void:
	hit_sound.pitch_scale = randf_range(0.6, 1.3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_update_behavior(delta)
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta

func _update_behavior(_delta: float) -> void:
	pass

func do_walk() -> void:
	if wall_ray.is_colliding() or not floor_ray.is_colliding():
		_direction = -_direction
		flip_sprite()
		flip_raycasts()
	velocity.x = _direction * speed

func flip_sprite() -> void:
	animated_sprite_2d.flip_h = _direction == 1

func flip_raycasts() -> void:
	wall_ray.target_position.x *= -1
	floor_ray.position.x *= -1

func _on_stomp_box_stomped() -> void:
	if _hit: return
	hit_area.set_deferred("monitorable", false)
	animated_sprite_2d.play("hit")
	hit_sound.play()
	_hit = true
	set_physics_process.call_deferred(false)


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "hit":
		SignalHub.emit_spawn_scene(global_position, EXPLOSION)
		var tween: Tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "rotation", 360, 0.5)
		tween.parallel().tween_property($AnimatedSprite2D, "scale", animated_sprite_2d.scale, 0.5)
		tween.tween_interval(1.0)
		tween.tween_property($AnimatedSprite2D, "rotation", 720, 0.5)
		tween.parallel().tween_property($AnimatedSprite2D, "scale", Vector2(0.0, 0.0), 0.5)
		if !hit_sound.playing:
			queue_free()
		_die_on_sound = true

func _on_timer_timeout() -> void:
	pass


func _on_hit_sound_finished() -> void:
	if _die_on_sound:
		queue_free()
