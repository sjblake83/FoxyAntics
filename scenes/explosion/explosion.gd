class_name Explosion
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var timer: Timer = $Timer

func _ready() -> void:
	var explosion_intensity = randf_range(0.7, 1.2)
	var explosion_scale = explosion_intensity - 0.4
	var explosion_rotation = randf_range(0, 360)
	explosion_sound.pitch_scale = explosion_intensity
	animated_sprite_2d.speed_scale = explosion_intensity
	animated_sprite_2d.scale = Vector2(explosion_scale, explosion_scale)
	animated_sprite_2d.rotation_degrees = explosion_rotation
	
	explosion_sound.play()
	timer.start()

func _on_timer_timeout() -> void:
	print("Timer timeout.")
	queue_free.call_deferred()
