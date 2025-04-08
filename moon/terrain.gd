class_name Terrain
extends Node3D

signal finished()

@export var player: Player

@export_category("Scatter Generation")
@export var scatter_noise: FastNoiseLite
@export var max_scatter := 0.3
@export var min_scatter := 0.0

@export_category("Cave Generation")
@export var cave_noise: FastNoiseLite
@export var cave_noise_threshold := -0.5
@export var min_cave_distance := 50.0
@export var cave_scene : PackedScene
@export var cave_sample_points := 10

@export_category("Terrain Generation")
@export var height_noise: FastNoiseLite
@export var chunk_size := 32
@export var render_distance := 4
@export var chunk_resolution := 1.0
@export var max_height := 20.0

var has_finished = false
var active_chunks := {}
var placed_caves := []

func apply_seed(seed: int):
	height_noise.seed = seed
	scatter_noise.seed = seed
	cave_noise.seed = seed

func _process(_delta):
	if not player:
		return
	
	update_chunks()
	if not has_finished:
		has_finished = true
		finished.emit()

func update_chunks():
	var player_pos = player.global_transform.origin
	var player_chunk_x = int(player_pos.x / (chunk_size * chunk_resolution))
	var player_chunk_z = int(player_pos.z / (chunk_size * chunk_resolution))
	
	var new_chunks := {}
	
	# Load chunks in render distance
	for x in range(player_chunk_x - render_distance, player_chunk_x + render_distance + 1):
		for z in range(player_chunk_z - render_distance, player_chunk_z + render_distance + 1):
			var chunk_key = Vector2(x, z)
			var chunk = _render_chunk(chunk_key)
			generate_cave_entrances(chunk)
			new_chunks[chunk_key] = chunk
	
	# Unload old chunks
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
	return new_chunk

func generate_cave_entrances(chunk: TerrainChunk):
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(chunk.chunk_position)
	
	var step = chunk_size / float(cave_sample_points)
	var chunk_world = chunk.chunk_position * chunk_size
	
	for x in cave_sample_points:
		for z in cave_sample_points:
			var local_x = x * step
			var local_z = z * step
			var world_x = chunk_world.x + local_x
			var world_z = chunk_world.y + local_z
			
			# Get cave noise value
			var cave_value = cave_noise.get_noise_2d(world_x, world_z)
			
			# Check threshold and minimum distance
			if cave_value < cave_noise_threshold:
				var candidate_pos = Vector2(world_x, world_z)
				if is_position_valid(candidate_pos):
					var height = chunk.get_height(local_x, local_z)
					var cave = cave_scene.instantiate()
					chunk.add_child(cave)
					cave.position = Vector3(local_x, height, local_z)
					
					placed_caves.append(candidate_pos)

func is_position_valid(pos: Vector2) -> bool:
	for existing_cave in placed_caves:
		if pos.distance_to(existing_cave) < min_cave_distance:
			return false
	return true
