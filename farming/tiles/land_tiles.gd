class_name LandTiles
extends TileMapLayer

var is_watered = {}

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate = Color.LIGHT_GRAY
	
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return is_watered.has(coords)
