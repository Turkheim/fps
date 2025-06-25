extends CharacterBody3D

var speed = 3.5
var gravity = 9.8
var health = 50
var state = "Idle"
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var knight: Node3D = $Knight

func _ready() -> void:
	state = "idle"
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta 
		
	elif state == "idle":
		velocity = Vector3.ZERO
		
	elif state == "pursue":
		velocity.y = 0
		var next_location = nav.get_next_path_position()
		var current_location = global_transform.origin
		var new_velocity = (next_location - current_location). normalized() * speed
	
		velocity = velocity.move_toward(new_velocity,0.25)
		knight.look_at(transform.origin + velocity * Vector3(1,0,1), Vector3.UP)
	
	elif state == "attack":
		velocity = Vector3.ZERO
		knight.look_at(transform.origin + velocity * Vector3(1,0,1), Vector3.UP)
	
	move_and_slide()
	
	
	
func target_position(target):
	nav.target_position = target


func _on_aggro_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = "pursue"
		$Knight/AnimationPlayer.play("Walkcycle")

func _on_disengage_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = "idle"
		$Knight/AnimationPlayer.play("Idle")

func _on_attack_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = "attack"
		$Knight/AnimationPlayer.play("Attack")


func _on_attack_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = "pursue"
		$Knight/AnimationPlayer.play("Walkcycle")

func _print_something():
	health = health - 10
	if health <= 0:
		queue_free()
