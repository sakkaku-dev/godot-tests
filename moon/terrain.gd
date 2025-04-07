class_name Terrain
extends Node

signal finished()

@export var chunk_size := 32
@export var render_distance := 4
@export var chunk_resolution := 1.0
@export var max_height := 20.0

@export var player: Player
@export var height_noise: FastNoiseLite
@export var scatter_noise: FastNoiseLite

var has_finished = false
var active_chunks := {}

func apply_seed(seed: int):
	height_noise.seed = seed
	scatter_noise.seed = seed

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
			
			if active_chunks.has(chunk_key):
				new_chunks[chunk_key] = active_chunks[chunk_key]
			else:
				var new_chunk = TerrainChunk.new()
				new_chunk.chunk_size = chunk_size
				new_chunk.resolution = chunk_resolution
				new_chunk.chunk_position = chunk_key
				new_chunk.noise = height_noise
				new_chunk.noise_height = max_height
				new_chunk.scatter_noise = scatter_noise
				new_chunk.generate_chunk()
				
				# Position the chunk correctly
				new_chunk.position = Vector3(
					x * (chunk_size - 1) * chunk_resolution,
					0,
					z * (chunk_size - 1) * chunk_resolution
				)
				
				add_child(new_chunk)
				new_chunks[chunk_key] = new_chunk
	
	# Unload old chunks
	for chunk_key in active_chunks:
		if not new_chunks.has(chunk_key):
			active_chunks[chunk_key].queue_free()
	
	active_chunks = new_chunks
