extends Node


signal spawn_scene(pos: Vector2, scene: PackedScene)


func emit_spawn_scene(pos: Vector2, scene: PackedScene):
	spawn_scene.emit(pos, scene)
