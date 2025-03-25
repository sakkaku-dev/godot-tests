@tool
extends Node

@export var grid_map: CaveGrid
@export var noise: Noise
@export var threshold := 0.6

@export var resource_scene: PackedScene
@export var root: Node3D
@export var run := false:
	set(v):
		generate_resources()

var resources := []

func generate_resources(seed: int = 0):
	noise.seed = seed

	for c in grid_map.get_used_cells():
		var neighbors = grid_map.get_solid_neighbors_6(c)
		if neighbors.size() < 6: continue

		var n = noise.get_noise_3d(c.x, c.y, c.z)
		if n > threshold:
			resources.append(c)
	
	_spawn_resources()

func _spawn_resources():
	for res in resources:
		# TODO: test the scatter addon
		var instance = resource_scene.instance()
		instance.position = grid_map.map_to_world(res)
		root.add_child(instance)
