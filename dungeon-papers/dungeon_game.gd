extends Node

const ITEMS = {
	"Metal": preload("res://dungeon-papers/item/metal.tscn"),
	"MoltenMetal": preload("res://dungeon-papers/item/molten_metal.tscn"),
}

const STATIONS = {
	"Furnace": preload("res://dungeon-papers/stations/furnace.tscn"),
	"Anvil": preload("res://dungeon-papers/stations/anvil.tscn"),
	"CuttingBoard": preload("res://dungeon-papers/stations/cutting_board.tscn"),
	"ItemBox": preload("res://dungeon-papers/stations/item_box.tscn"),
}

enum GameState {PREP, ROUND, END}
var current_state: GameState = GameState.PREP

func start_round():
	current_state = GameState.ROUND

func is_prepping():
	return current_state == GameState.PREP

func end_round():
	current_state = GameState.PREP

func get_item_scene(item_name: String) -> PackedScene:
	if item_name in ITEMS:
		return ITEMS[item_name]
	return null
