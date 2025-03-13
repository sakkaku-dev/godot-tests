# https://www.youtube.com/watch?v=qdskE8PJy6Q
# https://github.com/joebinns/stylised-character-controller/blob/main/Assets/Scripts/Physics%20Based%20Character%20Controller/PhysicsBasedCharacterController.cs
extends RigidBody3D

@export_category("Projectile")
@export var projectile_scene: PackedScene
@export var spawn_position: Node3D
@export var max_throw_strength := 5.0

@export_category("Rotation")
@export var upright_joint_spring_strength := 10
@export var upright_joint_spring_damper := 1.5

@export_category("Movement")
@export var max_speed := 8
@export var acceleration := 100
@export var acceleration_factor_from_dot: Curve
@export var max_accel_force := 150
@export var max_acceleration_factor_from_dot: Curve
@export var force_scale := Vector3(1, 0, 1)
@export var jump_force := 20

@onready var player_input: PlayerInput = $PlayerInput
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast
@onready var body: Node3D = $Body
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var chargeable: Chargeable = $Chargeable
#@onready var paint_emitter: PaintEmitter = $Body/PaintEmitter

var is_jumping := false
var jump_ready := false
var should_maintain_height := false

var gravitational_force := Vector3.DOWN * 10
var fall_gravity_factor := 10.0
var rise_gravity_factor := 5.0
var low_jump_factor := 2.5

var time_since_jump_pressed := 0.0
var time_since_ungrounded := 0.0

var goal_vel := Vector3.ZERO
var input_id := ""
var color := Color.WHITE

func _ready() -> void:
	#paint_emitter.color = color
	player_input.set_for_id(input_id)
	player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("throw"):
			chargeable.start()
		elif ev.is_action_pressed("throw_cancel"):
			chargeable.stop()
	)
	player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("throw"):
			#var node = projectile_scene.instantiate()
			#paint_emitter.throw_force = chargeable.value * max_throw_strength
			#paint_emitter.fire()
			#node.rotation.y = spawn_position.global_rotation.y
			#node.position = spawn_position.global_position
			#get_tree().current_scene.add_child(node)
			chargeable.stop()
	)

func _physics_process(delta: float) -> void:
	_move_player(delta)
	_apply_jump(ground_spring_cast.is_grounded())
	_float_above_ground()
	_restore_upright_rotation()

func _apply_jump(grounded: bool):
	if not grounded:
		is_jumping = false
	
	if linear_velocity.y < 0:
		should_maintain_height = true
		jump_ready = true

		if not grounded:
			apply_central_force(gravitational_force * (fall_gravity_factor - 1.0))
	elif linear_velocity.y > 0:
		if not grounded:
			if is_jumping:
				apply_central_force(gravitational_force * (fall_gravity_factor - 1.0))
			elif not player_input.is_pressed("jump"):
				apply_central_force(gravitational_force * (low_jump_factor - 1.0))

	if jump_ready and player_input.is_pressed("jump") and grounded:
		jump_ready = false
		should_maintain_height = false
		is_jumping = true
		apply_central_impulse(Vector3.UP * jump_force)

func get_move_dir():
	var motion = player_input.get_vector("move_right", "move_left", "move_down", "move_up")
	var move_dir = Vector3(motion.x, 0, motion.y)
	if move_dir.length() > 1:
		move_dir = move_dir.normalized()
	return move_dir

func _move_player(delta: float):
	var move_dir = get_move_dir()
	
	var aim = player_input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim:
		body.basis = Basis.looking_at(Vector3(aim.x, 0, aim.y))
	else:
		if chargeable.is_charging:
			var offset = -PI * 0.5
			var screen_pos = get_viewport().get_camera_3d().unproject_position(body.global_transform.origin)
			var mouse_pos = get_viewport().get_mouse_position()
			var angle = screen_pos.angle_to_point(mouse_pos)
			body.rotation.y = -(angle + offset)
		elif move_dir:
			body.basis = Basis.looking_at(-move_dir)
	
	var unit_vel = goal_vel.normalized()
	var vel_dot = move_dir.dot(unit_vel)
	var accel = acceleration * _curve_minus_range(acceleration_factor_from_dot, vel_dot)
	
	var current_target_vel = move_dir * max_speed
	goal_vel = goal_vel.move_toward(current_target_vel, accel * delta)
	
	var needed_accel = (goal_vel - linear_velocity) / delta
	var max_accel = max_accel_force * _curve_minus_range(max_acceleration_factor_from_dot, vel_dot)
	needed_accel = needed_accel.limit_length(max_accel)
	
	var force = needed_accel * mass
	apply_central_force(force)

func _curve_minus_range(curve: Curve, value: float):
	var scaled_value = (value + 1.0) / 2.0
	return curve.sample(scaled_value)

func _float_above_ground():
	var ground_vel = ground_spring_cast.apply_spring_force(linear_velocity)
	apply_central_force(ground_vel)

func _restore_upright_rotation():
	var upright_rotation = Basis().rotated(Vector3.UP, 0)
	var current_rotation = transform.basis
	var target_rotation = upright_rotation
	var rotation_difference = (target_rotation * current_rotation.inverse()).get_rotation_quaternion()

	var axis = rotation_difference.get_axis()
	var angle = rotation_difference.get_angle()

	apply_torque(axis * angle * upright_joint_spring_strength - (angular_velocity * upright_joint_spring_damper))
