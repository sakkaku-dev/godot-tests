extends RigidBody3D

@onready var area_3d: Area3D = $Area3D

var throw_force := 0.0

func _ready() -> void:
	var dir = Vector3.BACK.rotated(Vector3.UP, global_rotation.y)
	apply_central_impulse(dir * throw_force)
	
	area_3d.body_entered.connect(func(_b): queue_free())
