@tool
extends GridMap

@export var size := 50
@export var mesh_instance: MarchingCubes
@export var generate := false:
	set(v):
		run()

func run():
	mesh_instance.init_grid(size)
	for c in get_used_cells():
		mesh_instance.set_empty(c)
	mesh_instance.build_mesh()
