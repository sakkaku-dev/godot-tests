extends Node3D

@export var zip_line: PackedScene
@export var ammo := 1

func fire():
	if ammo <= 0:
		return
	
	var line = zip_line.instantiate() as Node3D
	line.basis = Basis.looking_at(Vector3.FORWARD * get_viewport().get_camera_3d().global_basis)
	line.position = global_position
	get_tree().current_scene.add_child(line)
