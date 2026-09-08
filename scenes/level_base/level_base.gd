extends Node

@onready var explosion_spawn: Node2D = $ExplosionSpawn
const EXPLOSION = preload("uid://dqtieift6vkhn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		var explosion_position = Vector2(
			explosion_spawn.position.x + randf_range(-100.0, +100.0),
			explosion_spawn.position.y + randf_range(-100.0, +100.0)
		)
		SignalHub.emit_spawn_scene(explosion_position, EXPLOSION)
