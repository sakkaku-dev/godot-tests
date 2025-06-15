class_name SeedPlaceholder
extends Node

@export var seed: Tiles.Seed

func do_action(tiles: Tiles):
	var mouse_pos = tiles.get_mouse_coord()
	if not tiles.is_plantable(mouse_pos): return
	
	tiles.place_seed(mouse_pos, seed)
