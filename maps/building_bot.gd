class_name BuildingBot
extends Node3D

@export var mesh: MeshInstance3D

func set_material(mat: Material):
	mesh.material_override = mat
