class_name GroundSpringCast
extends RayCast3D

@export var spring_strength := 20.0
@export var ride_height := 0.5
@export var damping := 1.0

@onready var gravity = 50 #ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	target_position = target_position.normalized() * ride_height

func apply_gravity(player: CharacterBody3D, delta: float):
	if not is_grounded():
		player.velocity.y -= gravity * delta
	else:
		player.velocity.y += apply_spring_force(player.velocity).y

func apply_spring_force(velocity: Vector3) -> Vector3:
	var ray_dir = target_position.normalized()
	var ground_vector = get_collision_point() - global_position
	
	var rel_velocity = ray_dir.dot(velocity)
	var displacement = ground_vector.length() - ride_height
	var force = (displacement * spring_strength) - (rel_velocity * damping)
	
	return ray_dir * force

func is_grounded():
	return is_colliding()
