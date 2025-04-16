class_name Terrain
extends Node3D

signal finished()

@export var player: Player
@export var resources: Array[TerrainResource] = []

@export_category("Terrain Generation")
@export var height_noise: FastNoiseLite
@export var chunk_size := 32
@export var render_distance := 4
@export var chunk_resolution := 1.0
@export var max_height := 20.0

var has_finished = false
var active_chunks := {}
var placed_resources := {}

func apply_seed(s: int):
	height_noise.seed = s
	for res in resources:
		res.noise.seed = s

func _process(_delta):
	if not player:
		return
	
	update_chunks()
	if not has_finished:
		has_finished = true
		finished.emit()

func update_chunks():
	var global_chunk_size = chunk_size * chunk_resolution
	var player_pos = player.global_transform.origin
	var player_chunk_x = int(player_pos.x / global_chunk_size)
	var player_chunk_z = int(player_pos.z / global_chunk_size)
	
	var new_chunks := {}
	
	for x in range(player_chunk_x - render_distance, player_chunk_x + render_distance + 1):
		for z in range(player_chunk_z - render_distance, player_chunk_z + render_distance + 1):
			var chunk_key = Vector2(x, z)
			new_chunks[chunk_key] = _render_chunk(chunk_key)
	
	for chunk_key in active_chunks:
		if not new_chunks.has(chunk_key):
			active_chunks[chunk_key].queue_free()
	
	active_chunks = new_chunks

func _render_chunk(chunk_key):
	if active_chunks.has(chunk_key):
		return active_chunks[chunk_key]

	var new_chunk = TerrainChunk.new()
	new_chunk.chunk_size = chunk_size
	new_chunk.resolution = chunk_resolution
	new_chunk.chunk_position = chunk_key
	new_chunk.noise = height_noise
	new_chunk.noise_height = max_height
	new_chunk.generate_chunk()
	
	new_chunk.position = Vector3(
		chunk_key.x * (chunk_size - 1) * chunk_resolution,
		0,
		chunk_key.y * (chunk_size - 1) * chunk_resolution
	)
	
	add_child(new_chunk)
	generate_resources_for_chunk(new_chunk)
	return new_chunk

func generate_resources_for_chunk(chunk: TerrainChunk):
	for res in resources:
		generate_resource(chunk, res)

func generate_resource(chunk: TerrainChunk, res: TerrainResource):
	var step = chunk_size / float(res.sample_points)
	var chunk_world = chunk.chunk_position * chunk_size
	var chunk_resources = ResourceManager.get_resource(chunk.chunk_position)
	
	var id = 0
	for x in res.sample_points:
		for z in res.sample_points:
			if id in chunk_resources: continue

			var local_x = x * step
			var local_z = z * step
			var world_x = chunk_world.x + local_x
			var world_z = chunk_world.y + local_z
			
			var value = res.noise.get_noise_2d(world_x, world_z)
			if value < res.threshold:
				var candidate_pos = Vector2(world_x, world_z)
				# if is_position_valid(candidate_pos):
				var height = chunk.get_height(local_x, local_z)
				var node = res.scene.instantiate()
				node.set("chunk_key", chunk.chunk_position)
				node.set("resource_id", id)
				chunk.add_child(node)
				node.position = Vector3(local_x, height, local_z)
				id += 1

# func is_position_valid(pos: Vector2) -> bool:
# 	for existing_cave in placed_caves:
# 		if pos.distance_to(existing_cave) < min_cave_distance:
# 			return false
# 	return true
