extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.fell_off()
	if body is EnemyBase:
		body.queue_free()
