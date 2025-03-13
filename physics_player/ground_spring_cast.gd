class_name GroundSpringCast
extends RayCast3D

@export var spring_strength := 100.0
@export var ride_height := 1.0
@export var damping := 3.0

func _ready() -> void:
	target_position = target_position.normalized() * ride_height * 1.5

func apply_spring_force(velocity: Vector3) -> Vector3:
	if not is_grounded(): return Vector3.ZERO
		
	var ray_dir = target_position.normalized()
	var ground_vector = get_collision_point() - global_position
	
	var rel_velocity = ray_dir.dot(velocity)
	var displacement = ground_vector.length() - ride_height
	var force = (displacement * spring_strength) - (rel_velocity * damping)
	
	return ray_dir * force

func is_grounded():
	return is_colliding()
