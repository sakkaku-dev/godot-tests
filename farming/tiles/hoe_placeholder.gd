class_name HoePlaceholder
extends Node

@export var source_id = 0
@export var atlas = Vector2i.ZERO

func do_action(tiles: Tiles):
	var mouse_pos = tiles.get_mouse_coord()
	if not tiles.is_ground_free(mouse_pos): return
	
	tiles.farm.set_cell(mouse_pos, source_id, atlas)

func do_secondary(tiles: Tiles):
	var mouse_pos = tiles.get_mouse_coord()
	if tiles.is_ground_free(mouse_pos): return
	
	tiles.land.set_cell(mouse_pos, -1)
