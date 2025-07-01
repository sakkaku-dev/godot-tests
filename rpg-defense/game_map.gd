class_name GameMap
extends GridMap

signal disabled_placement()

const LINEAR_NEIGHBORS = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
const DIAGONAL_NEIGHBORS = [Vector3i(1, 0, 1), Vector3i(-1, 0, -1), Vector3i(-1, 0, 1), Vector3i(1, 0, -1)]

@export var start_coords: Array[Vector3i] = []
@export var block_scene: PackedScene

var can_place_blocks := true:
	set(v):
		can_place_blocks = v
		if not v:
			disabled_placement.emit()

var objects := {}
var min_cell = Vector3i(0, 0, 0)
var max_cell = Vector3i(0, 0, 0)

func _ready() -> void:
	for cell in get_used_cells():
		min_cell.x = min(min_cell.x, cell.x)
		min_cell.z = min(min_cell.z, cell.z)
		max_cell.x = max(max_cell.x, cell.x)
		max_cell.z = max(max_cell.z, cell.z)

func place_block(block: BlockResource, cell: Vector3i) -> void:
	if not block or not cell or not can_place_blocks:
		return
	
	if cell in objects:
		print("Cell already occupied: ", cell)
		return
	
	if is_outside(cell):
		print("Cell out of bounds: ", cell)
		return

	var block_instance = block_scene.instantiate()
	block_instance.res = block
	block_instance.position = map_to_local(cell)
	add_child(block_instance)
	objects[cell] = block_instance

func is_outside(cell: Vector3i) -> bool:
	return cell.x < min_cell.x or cell.x > max_cell.x or cell.z < min_cell.z or cell.z > max_cell.z

func get_moveable_neighbors(cell: Vector3i, exclude = [], blocked_objects = objects):
	var result = []
	for c in LINEAR_NEIGHBORS:
		var next_cell = cell + c
		if next_cell in blocked_objects or is_outside(next_cell) or next_cell in exclude:
			continue
		
		result.append(next_cell)
	
	for c in DIAGONAL_NEIGHBORS:
		var next_cell = cell + c
		if next_cell in blocked_objects or is_outside(next_cell) or next_cell in exclude:
			continue

		if Vector3i(next_cell.x, next_cell.y, 0) not in result or Vector3i(0, next_cell.y, next_cell.z) not in result:
			continue
		
		result.append(next_cell)

	return result
