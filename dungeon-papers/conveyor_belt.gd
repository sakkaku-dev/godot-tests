class_name ConveyorBelt
extends Area3D

@export var speed: float = 2.0
@export var direction: Vector3 = Vector3.RIGHT

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.linear_velocity = (direction.normalized() * speed * body.mass)
