class_name DungeonMap
extends GridMap

@export var floor_item := 0

func get_snapped_position(pos: Vector3):
	var cell = local_to_map(pos)
	var cell_item = get_cell_item(cell)

	print(cell_item)
	if cell_item != floor_item:
		return null

	return map_to_local(cell)
