extends Node

var chunk_data: Dictionary[Vector2, Dictionary] = {}

func save_chunk_data(chunk_key: Vector2, data: Dictionary):
	chunk_data[chunk_key] = data

func remove_resource(chunk_key: Vector2, resource_id: int):
	if not chunk_data.has(chunk_key):
		chunk_data[chunk_key] = {}

	var chunk_resources = chunk_data[chunk_key]
	chunk_resources[resource_id] = {}

func get_resource(chunk_key: Vector2):
	if chunk_data.has(chunk_key):
		return chunk_data[chunk_key]
	return {}
