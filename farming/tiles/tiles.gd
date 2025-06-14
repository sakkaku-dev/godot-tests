class_name Tiles
extends Node2D

@export var seed_source := 2

@onready var water: TileMapLayer = $Water
@onready var grass: TileMapLayer = $Grass
@onready var land: TileMapLayer = $Land
@onready var house: TileMapLayer = $House
@onready var roof: TileMapLayer = $Roof
@onready var farm: TileMapLayer = $Farm

func _ready() -> void:
	FarmManager.seed_changed.connect(func(coord: Vector2i, seed: FarmManager.Seed, stage: int):
		farm.set_cell_source_id(coord, seed_source, Vector2i(stage + 1, seed))
	)

func get_current_mouse_position():
	var mouse = get_mouse_coord()
	return water.map_to_local(mouse)

func get_mouse_coord():
	return water.local_to_map(get_global_mouse_position())

func is_ground_free(coord: Vector2i):
	var layers = [land, house]
	for l in layers:
		if l.get_cell_source_id(coord) != -1:
			return false
	return true

func is_plantable(coord: Vector2i):
	return land.get_cell_source_id(coord) != -1
