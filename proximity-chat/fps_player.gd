class_name Player
extends CharacterBody3D

signal player_ready()
signal weapon_changed()
signal ammo_changed()

@export var SPEED = 6.0
@export var ZIP_SPEED = 0.1
@export var JUMP_VELOCITY = 8.0

@export var mouse_sensitivity := Vector2(0.001, 0.001)
@export var aim_sensitivity := Vector2(0.0003, 0.0003)
@export var body: Node3D
@export var hand: Hand

@export var camera: Camera3D
@export var camera_root: Node3D

var gravity = 8.0

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
		body.hide()
	
	DebugWindow.add_action("speed", func(v): SPEED = float(v))
	DebugWindow.add_action("gravity", func(v): gravity = float(v))
	
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

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if hand.zip_follow:
		if Input.is_action_just_pressed("jump"):
			hand.remove_zip()
			velocity.y = JUMP_VELOCITY
		else:
			var zip_dir = hand.get_zip_direction()
			var zip_move_dir = sign(zip_dir.dot(direction))
			
			#if hand.zip_follow.progress_ratio >= 0.00 and hand.zip_follow.progress_ratio <= 1.0:
			hand.zip_follow.progress += zip_dir.dot(direction) * ZIP_SPEED
			hand.zip_follow.progress_ratio = clamp(hand.zip_follow.progress_ratio, 0.05, 0.95)
			return
	else:
		if not is_on_floor():
			velocity.y -= gravity * delta

		if Input.is_action_just_pressed("jump"): # and is_on_floor():
			velocity.y = JUMP_VELOCITY

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
