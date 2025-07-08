# https://www.youtube.com/watch?v=qdskE8PJy6Q
# https://github.com/joebinns/stylised-character-controller/blob/main/Assets/Scripts/Physics%20Based%20Character%20Controller/PhysicsBasedCharacterController.cs
class_name PhysicsCharacter
extends RigidBody3D

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

@onready var body: Node3D = $Body
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast

var speed_multiplier := 1.0
var gravitational_force := Vector3.DOWN * 10
var goal_vel := Vector3.ZERO

func _physics_process(delta: float) -> void:
	_move_player(delta)
	_float_above_ground()
	_restore_upright_rotation()

func get_move_dir():
	return Vector3.ZERO
	
func get_aim_dir():
	return Vector3.ZERO

func _move_player(delta: float):
	var move_dir = get_move_dir()
	var aim_dir = get_aim_dir()
	
	if aim_dir:
		body.basis = Basis.looking_at(aim_dir)
	elif move_dir:
		body.basis = Basis.looking_at(-move_dir)
	
	var unit_vel = goal_vel.normalized()
	var vel_dot = move_dir.dot(unit_vel)
	var accel = acceleration * _curve_minus_range(acceleration_factor_from_dot, vel_dot)
	
	var current_target_vel = move_dir * max_speed * speed_multiplier
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
