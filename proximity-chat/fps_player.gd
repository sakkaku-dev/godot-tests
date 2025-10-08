class_name Player
extends CharacterBody3D

@export var SPEED = 8.0
@export var mouse_sensitivity := Vector2(0.003, 0.002)

@export var camera: Camera3D
@export var camera_root: Node3D
@export var hand: Hand3D

@onready var player_input: PlayerInput = $PlayerInput

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if Networking.has_network():
		var is_authority = is_multiplayer_authority()
		camera.current = is_authority
		set_process_unhandled_input(is_authority)
		set_physics_process(is_authority)
	else:
		camera.current = true
	
	hand.released.connect(func(): camera.current = true)
	player_input.input_event.connect(func(event: InputEvent):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			if event is InputEventMouseMotion:
				var sens = mouse_sensitivity
				rotate_y(-event.relative.x * sens.x)
				camera_root.rotate_x(-event.relative.y * sens.y)
				camera_root.rotation.x = clamp(camera_root.rotation.x, deg_to_rad(-70), deg_to_rad(70))
			elif event.is_action_pressed("ui_cancel"):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE
			elif event.is_action_pressed("interact"):
				var cam = hand.interact()
				if cam:
					cam.current = true
	)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = player_input.get_vector("move_left", "move_right", "move_up", "move_down")
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
