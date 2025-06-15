extends Node

@export var source_id = 0
@export var atlas = Vector2i.ZERO

func do_action(tiles: Tiles):
	var mouse_pos = tiles.get_mouse_coord()
	tiles.water_seed(mouse_pos)
