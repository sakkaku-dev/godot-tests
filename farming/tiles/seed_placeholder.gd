class_name SeedPlaceholder
extends Node

@export var seed: FarmManager.Seed

func do_action(tiles: Tiles):
	print("Try planting seed")
	var mouse_pos = tiles.get_mouse_coord()
	if not tiles.is_plantable(mouse_pos): return
	
	print("Is plantable")
	FarmManager.place_seed(mouse_pos, seed)
