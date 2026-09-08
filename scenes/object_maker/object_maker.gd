extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.spawn_scene.connect(on_spawn_scene)


func on_spawn_scene(pos: Vector2, scene: PackedScene):
	if !scene: return
	var new_scene = scene.instantiate()
	
	if new_scene is Node2D:
		new_scene.global_position = pos
	add_child.call_deferred(new_scene)
