class_name Player
extends CharacterBody3D

signal player_ready()
signal weapon_changed()
signal ammo_changed()

@export var SPEED = 8.0
@export var JUMP_VELOCITY = 4.5

@export var mouse_sensitivity := Vector2(0.001, 0.001)
@export var aim_sensitivity := Vector2(0.0003, 0.0003)
@export var body: Node3D

@export var camera: Camera3D
@export var camera_root: Node3D
@export var light: Light3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if Networking.has_network():
		var is_authority = is_multiplayer_authority()
		camera.current = is_authority
		set_process_unhandled_input(is_authority)
		set_physics_process(is_authority)
		body.visible = not is_authority
	else:
		camera.current = true

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sens = mouse_sensitivity #aim_sensitivity if Input.is_action_pressed("weapon_aim") else mouse_sensitivity
		rotate_y(-event.relative.x * sens.x)
		camera_root.rotate_x(-event.relative.y * sens.y)
		camera_root.rotation.x = clamp(camera_root.rotation.x, deg_to_rad(-70), deg_to_rad(70))
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("flashlight"):
		light.light_energy = 0 if light.light_energy > 0 else 1

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var _speed = SPEED
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * _speed
			velocity.z = direction.z * _speed
		else:
			velocity.x = lerp(velocity.x, direction.x * _speed, delta * 15.0)
			velocity.z = lerp(velocity.z, direction.z * _speed, delta * 15.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * _speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * _speed, delta * 3.0)

	move_and_slide()
