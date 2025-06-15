class_name Tiles
extends Node2D

signal seed_changed(coord: Vector2i, data: Dictionary)

enum Seed {
	WEED,
}

@export var seed_source := 2
@export var seed_final_stage = 4
@export var drop_scene: PackedScene

@onready var water: TileMapLayer = $Water
@onready var grass: TileMapLayer = $Grass
@onready var land: LandTiles = $Land
@onready var house: TileMapLayer = $House
@onready var roof: TileMapLayer = $Roof
@onready var farm: TileMapLayer = $Farm

var plants = {}

func _ready() -> void:
	seed_changed.connect(func(coord: Vector2i, data: Dictionary):
		if data == null:
			farm.set_cell(coord, -1)
		else:
			farm.set_cell(coord, seed_source, Vector2i(data.stage + 1, data.type))
	)

func do_process():
	print("Processing farm")
	for p in plants:
		var plant = plants[p]
		
		if plant.stage > seed_final_stage:
			plant.ready = true
			continue
		
		plant.stage += 1
		seed_changed.emit(p, plant)

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

func is_land(coord: Vector2i):
	return land.get_cell_source_id(coord) != -1

func is_plantable(coord: Vector2i):
	return is_land(coord) and not coord in plants

func place_seed(coord: Vector2i, seed: Seed):
	if not is_plantable(coord): return
	
	plants[coord] = { "type": seed, "stage": 0, "ready": false }
	seed_changed.emit(coord, plants[coord])

func is_waterable(coord: Vector2i):
	return is_land(coord) and coord in plants and not coord in land.is_watered

func water_seed(coord: Vector2i):
	if not is_waterable(coord): return
	land.is_watered[coord] = true
	land.notify_runtime_tile_data_update()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		var coord = get_mouse_coord()
		if coord in plants and plants[coord].ready:
			plants.erase(coord)
			seed_changed.emit(coord, null)
			
			var drop = drop_scene.instantiate()
			drop.item = null # TODO
			drop.position = water.map_to_local(coord)
			get_tree().current_scene.add_child(drop)
