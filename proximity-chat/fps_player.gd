class_name Player
extends CharacterBody3D

signal player_ready()
signal weapon_changed()
signal ammo_changed()

@export var SPRINT_MULTIPLIER = 2.0
@export var SPEED = 4.0
@export var ZIP_SPEED = 0.1
@export var JUMP_VELOCITY = 8.0

@export var mouse_sensitivity := Vector2(0.001, 0.001)
@export var aim_sensitivity := Vector2(0.0003, 0.0003)
@export var body: Node3D
@export var hand: Hand

@export var camera: Camera3D
@export var camera_root: Node3D

@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast
@onready var jump_timer: Timer = $JumpTimer
@onready var player_input: PlayerInput = $PlayerInput

var gravity = 50
var has_jumped = false

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	jump_timer.timeout.connect(func(): has_jumped = false)
	
	if Networking.has_network():
		var is_authority = is_multiplayer_authority()
		camera.current = is_authority
		set_process_unhandled_input(is_authority)
		set_physics_process(is_authority)
		body.visible = not is_authority
	else:
		camera.current = true
		body.hide()
		
	player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("jump"):
			if hand.zip_follow:
				hand.remove_zip()
				velocity.y = JUMP_VELOCITY
			elif is_grounded() and not has_jumped:
				velocity.y = JUMP_VELOCITY
				has_jumped = true
				jump_timer.start()
	)

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
	var input_dir = player_input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if hand.zip_follow:
		var zip_dir = hand.get_zip_direction()
		var zip_move_dir = sign(zip_dir.dot(direction))
		
		#if hand.zip_follow.progress_ratio >= 0.00 and hand.zip_follow.progress_ratio <= 1.0:
		hand.zip_follow.progress += zip_dir.dot(direction) * ZIP_SPEED
		hand.zip_follow.progress_ratio = clamp(hand.zip_follow.progress_ratio, 0.05, 0.95)
		return
	else:
		if not is_grounded():
			velocity.y -= gravity * delta
		elif not has_jumped:
			var f = ground_spring_cast.apply_spring_force(velocity)
			velocity.y += f.y

	var _speed = SPEED * (SPRINT_MULTIPLIER if player_input.is_pressed("sprint") else 1.0)
	
	if is_grounded():
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

func is_grounded():
	return ground_spring_cast.is_grounded() #or is_on_floor()
