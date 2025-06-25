extends RigidBody3D

@export var pickable_arrow : PackedScene

func _physics_process(delta):
	if linear_velocity.length() > 0.2: # Add a small threshold to avoid jitter
		look_at(global_position + linear_velocity)
		
func _on_lifetime_timeout() -> void:
	queue_free()



func _on_area_3d_body_entered(body: Node3D) -> void:
	#self.freeze = true	

	if body.is_in_group("enemy"):
		if pickable_arrow:
			var new_arrow : Area3D = pickable_arrow.instantiate()
			if new_arrow:
				new_arrow.set_as_top_level(true)
				add_child(new_arrow)
				new_arrow.transform = self.global_transform
				new_arrow.set_as_top_level(false)
				var new_parent = body.knight
				new_arrow.reparent(new_parent)
				body._print_something()
				queue_free()

	else:
		_instanciate_pickable_arrow()
		
func 	_instanciate_pickable_arrow():
	if pickable_arrow:
		var new_arrow : Area3D = pickable_arrow.instantiate()
		if new_arrow:
			new_arrow.set_as_top_level(true)
			add_child(new_arrow)
			new_arrow.transform = self.global_transform
			var new_parent = self.get_parent()
			new_arrow.reparent(new_parent)

			queue_free()
