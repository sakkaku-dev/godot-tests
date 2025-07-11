class_name Ingredient
extends Item

@export var station_outputs: Dictionary[String, PackedScene] = {}

func can_station_process(station: Station) -> bool:
	for type in station_outputs:
		if station.item_name == type:
			return true
	return false

func get_output_for_station(station: Station) -> PackedScene:
	if not can_station_process(station):
		return null
	return station_outputs.get(station.item_name, null)
