class_name  Chicken

extends EnemyBase

enum ChickenState { WALK, FLY }

@onready var timer: Timer = $Timer

@export var jump_force: float = -250.0
@export var jump_lifetime: float = 3.0
@export var walk_duration: float = 1.5
@export var gravity_curve: Curve

var _state: ChickenState = ChickenState.WALK
var _in_air: float = 0.0
var _gravity_mult: float = 1.0

func _ready() -> void:
	change_state(ChickenState.WALK)

func _apply_gravity(delta: float) -> void:
	if _state == ChickenState.FLY and gravity_curve:
		var t: float = clampf(_in_air / jump_lifetime, 0.0, 1.0)
		_gravity_mult = gravity_curve.sample(t)
	velocity.y += gravity * delta * _gravity_mult

func _update_behavior(delta: float) -> void:
	match _state:
		ChickenState.WALK:
			do_walk()
		ChickenState.FLY:
			_in_air += delta
			if is_on_floor() and velocity.y >= 0:
				change_state(ChickenState.WALK)

func change_state(new_state: ChickenState) -> void:
	_state = new_state
	_gravity_mult = 1.0
	match _state:
		ChickenState.WALK:
			animated_sprite_2d.play("walk")
			timer.start(walk_duration)
		ChickenState.FLY:
			_in_air = 0.0
			animated_sprite_2d.play("fly")
			velocity.y = jump_force

func apply_bounce(bounce_velocity: Vector2) -> void:
	bounce_velocity.x = velocity.x
	velocity = bounce_velocity

func _on_timer_timeout() -> void:
	if _state == ChickenState.WALK:
		change_state(ChickenState.FLY)


func _on_hit_area_area_entered(area: Area2D) -> void:
	if area is Trampoline and velocity.y > 0:
		apply_bounce.call_deferred(area.bounce_velocity)
		area.bounce()
