class_name  Trampoline
extends Area2D

@export var bounce_velocity: Vector2 = Vector2(0, -400.0)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer = $Sound

func bounce() -> Vector2:
	animated_sprite_2d.stop()
	animated_sprite_2d.play("spring")
	sound.play()
	return bounce_velocity
