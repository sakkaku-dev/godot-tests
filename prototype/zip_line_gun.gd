extends Node3D

@export var zip_line: PackedScene
@export var ammo := 1

func fire():
	if ammo <= 0:
		return
	
	var line = zip_line.instantiate() as ZipLine
	line.position = global_position
	line.move_dir = -get_viewport().get_camera_3d().global_basis.z
	get_tree().current_scene.add_child(line)
