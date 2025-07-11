class_name DungeonMap
extends GridMap

const GROUP = "DungeonMap"

@export var floor_item := 0

func _ready() -> void:
	add_to_group(GROUP)

func get_snapped_position(pos: Vector3):
	var cell = local_to_map(pos)
	var cell_item = get_cell_item(cell)

	if cell_item != floor_item:
		return null

	return map_to_local(cell)
