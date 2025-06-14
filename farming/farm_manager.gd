extends Node

signal seed_changed(coord: Vector2i, seed: Seed, stage: int)

enum Seed {
	WEED,
}

var plants = {}

func place_seed(coord: Vector2i, seed: Seed):
	if coord in plants: return
	
	plants[coord] = seed
	print("Planted seed at ", coord, ": ", seed)
	seed_changed.emit(coord, seed, 0)
