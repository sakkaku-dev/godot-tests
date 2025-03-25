@tool
class_name CaveGrid
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

const NEIGHBOR_OFFSETS_6 = [
	Vector3(-1, 0, 0), Vector3(1, 0, 0),  # Left, Right
	Vector3(0, -1, 0), Vector3(0, 1, 0),  # Down, Up
	Vector3(0, 0, -1), Vector3(0, 0, 1)   # Backward, Forward
]
var NEIGHBOR_OFFSETS_26 = []

# func _ready():
# 	for dx in range(-1, 2):
# 		for dy in range(-1, 2):
# 			for dz in range(-1, 2):
# 				if dx != 0 or dy != 0 or dz != 0:
# 					NEIGHBOR_OFFSETS_26.append(Vector3(dx, dy, dz))

func count_solid_neighbors(x, y, z):
	return get_solid_neighbors(x, y, z).size()

func get_solid_neighbors(x, y, z):
	var result = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dy == 0 and dz == 0:
					continue
				
				var p = Vector3(x + dx, y + dy, z + dz)
				if not is_empty(p):
					result.append(p)
	
	return result

func get_solid_neighbors_6(pos: Vector3):
	var result = []
	for offset in NEIGHBOR_OFFSETS_6:
		var p = pos + offset
		if not is_empty(p):
			result.append(p)
	
	return result

func is_empty(p):
	return get_cell_item(p) == -1


func is_not_edge(pos: Vector3):
	return pos.x > 1 and pos.x < size - 1 \
		and pos.y > 1 and pos.y < size - 1 \
		and pos.z > 1 and pos.z < size - 1

func is_within(pos: Vector3):
	return pos.x >= 0 and pos.x < size \
		and pos.y >= 0 and pos.y < size \
		and pos.z >= 0 and pos.z < size

func get_neighbors_of_neighbors(pos: Vector3):
	var neighbors = get_solid_neighbors(pos.x, pos.y, pos.z)
	var result = []

	for n in neighbors:
		result.append(n)
		result.append_array(get_neighbors_of_neighbors(n))
		
	return result
