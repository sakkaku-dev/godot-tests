class_name SoftPush
extends ShapeCast3D

@export var max_push_force := 100.0

func get_push_force(target_dir: Vector3):
	var count = get_collision_count()
	
	var final_push = Vector3.ZERO
	for i in count:
		var point = get_collision_point(i)
		var dir = global_position.direction_to(point)
		var dist = global_position.distance_squared_to(point)
		final_push += -dir * max_push_force / dist

	return final_push
