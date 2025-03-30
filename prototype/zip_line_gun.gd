extends Node3D

@export var zip_line: PackedScene
@export var ammo := 1

func fire():
	if ammo <= 0:
		return

@rpc("reliable", "call_local")
func _spawn_bullet():
	var line = zip_line.instantiate() as ZipLine
	line.position = global_position
	line.move_dir = -get_viewport().get_camera_3d().global_basis.z
	get_tree().get_first_node_in_group("spawner").add_child(line)
