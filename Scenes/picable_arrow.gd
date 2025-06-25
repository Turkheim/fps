extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var new_arrow_count = body.arrow_count
		body.arrow_count = new_arrow_count + 1
		queue_free()
