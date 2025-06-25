extends Node3D

@onready var target: CharacterBody3D = $Player

func _process(delta: float) -> void:
	get_tree().call_group("enemy","target_position", target.global_transform.origin)
