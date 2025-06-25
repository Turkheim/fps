extends CharacterBody3D

@export var arrow : PackedScene

@export_range(1, 35, 1) var speed: float = 5 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var arrow_speed = 20.0
@export var arrow_count = 5



@onready var camera: Camera3D = $Camera
@onready var lose: AudioStreamPlayer3D = $Camera/Crossbow/Lose
@onready var load: AudioStreamPlayer3D = $Camera/Crossbow/load

var can_fire = false
@onready var visible_arrow: Node3D = $Camera/Crossbow/Arrow2

func _ready() -> void:
	capture_mouse()
	can_fire = true
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed(&"ui_cancel"): get_tree().quit()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_accept"): jumping = true
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	if Input.is_action_just_pressed(&"Fire") and can_fire:
		if arrow_count > 0:
			_fire_arrow()
		else:
			print("no arrow")
	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _fire_arrow():
	
	if arrow:
		var new_arrow : RigidBody3D = arrow.instantiate()
		if new_arrow:
			new_arrow.set_as_top_level(true)
			add_child(new_arrow)
			new_arrow.transform = $Camera/Crossbow/SpawnPoint.global_transform
			new_arrow.linear_velocity = new_arrow.transform.basis.z * arrow_speed * -1
	visible_arrow.visible = false
	lose.play()
	load.play()
	can_fire = false
	$Camera/Crossbow/Bow.play("bow")
	$Cooldown.start()
	arrow_count = arrow_count - 1
	

func _on_cooldown_timeout() -> void:
	
	can_fire = true
	if arrow_count > 0:
		visible_arrow.visible = true
