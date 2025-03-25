@tool
class_name EchoChamber
extends Area3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func set_aabb(aabb: AABB):
	global_position = aabb.get_center()
	
	var shape = BoxShape3D.new()
	shape.size = aabb.size / 2.0
	collision_shape_3d.shape = shape
