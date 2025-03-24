@tool
extends Node3D

@export var grid_size := 50

@export_category("Worm")
@export var num_worms := 10
@export var worm_length := 10
@export var worm_step_size := 3
@export var worm_radius := 4.0
@export var turn_noise_scale := 1.0
@export var radius_noise_scale := 1.0
@export var branch_chance := 0.01
@export var turn_factor := 0.1
@export var noise: Noise

@export var _generate := false:
	set(v):
		generate()

@export_category("Rooms")
@export var room_size := 10
@export var room_noise: Noise
@export var _generate_room := false:
	set(v):
		generate_room()

@export_category("Nodes")
@export var grid_map: GridMap
@export var mesh_instance_3d: MarchingCubes

@onready var stopwatch := Stopwatch.new()

func generate_room():
	grid_map.clear()
	carve_room(Vector3(grid_size / 2, grid_size / 2, grid_size / 2))

func generate(game_seed = 0):
	#stopwatch.start("Generate Cave")
	#
	#mesh_instance_3d.init_grid(grid_size)
	grid_map.clear()
	#seed(game_seed)
	
	var limit = _grid_limit()
	for i in range(num_worms):
		var pos = Vector3(randf_range(0, limit), grid_size, randf_range(0, limit))
		var dir = _random_direction()
		generate_branch(pos, dir, worm_length)
	
	#stopwatch.print_lap("Filled grid")
	#mesh_instance_3d.build_mesh()
	#stopwatch.print_lap("Build mesh")
	#stopwatch.finish()

func generate_branch(pos, dir, length, depth = 0):
	var coords := []
	var branch_chance := 0.0
	for i in range(length):
		var noise_value = noise.get_noise_3d(pos.x * turn_noise_scale, pos.y * turn_noise_scale, pos.z * turn_noise_scale)
		dir += turn_factor * Vector3(noise_value, noise_value, noise_value)
		dir = dir.normalized()

		pos += dir * worm_step_size
		_limit_inside_grid(pos)

		carve_sphere(pos)
		coords.append(pos)
		
		if pos.y <= worm_radius: continue

		if _has_reached_border(pos):
			dir = _new_random_direction_between(dir, -0.6, -0.4)
			continue
		
		if randf() < branch_chance and depth < 3:
			branch_chance = 0
			var new_dir = _new_random_direction_between(dir, -0.2, 0.2)
			generate_branch(pos, new_dir, length - i, depth + 1)
		else:
			branch_chance += 0.01

	#if randf() < branch_chance and depth < 3:a
		#carve_room(coords[coords.size() / 2])
	# 	var new_dir = _new_random_direction_between(dir, 0.2, 0.8)

	# 	var center = coords.size() / 2.0
	# 	pos = coords[int(center)] #coords[randi_range(center - center/2.0, center + center/2.0)]
	# 	print("Branching of at %s in %s" % [pos, new_dir])
	# 	generate_branch(pos, new_dir, length, depth + 1)

func _new_random_direction_between(dir: Vector3, from_dot: float, to_dot: float):
	var tries = 0
	var new_dir = _random_direction()
	while not (new_dir.dot(dir) >= from_dot and new_dir.dot(dir) <= to_dot):
		new_dir = _random_direction()
		tries += 1
		
		if tries >= 50:
			break
		
	return new_dir

func carve_sphere(pos):
	var multiplier = (2 + noise.get_noise_3d(pos.x * radius_noise_scale, pos.y * radius_noise_scale, pos.z * radius_noise_scale))
	var radius = round(worm_radius * multiplier)
	
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			for dz in range(-radius, radius + 1):
				if (dx ** 2 + dy ** 2 + dz ** 2) <= radius ** 2:
					var new_pos = pos + Vector3(dx, dy, dz)
					var xi = new_pos.x
					var yi = new_pos.y
					var zi = new_pos.z
					if _is_not_edge(new_pos):
						grid_map.set_cell_item(new_pos, 0)

func create_spikes(pos, dir, height):
	var breadth = randi_range(2, 6)
	
	for h in range(height):
		grid_map.set_cell_item(pos + dir * h, -1)

func carve_room(pos):
	for dx in range(-room_size, room_size + 1):
		for dy in range(-room_size, room_size + 1):
			for dz in range(-room_size, room_size + 1):
				var p = pos + Vector3(dx, dy, dz)
				grid_map.set_cell_item(p, 0)
				
				if dy == -room_size or dy == room_size:
					var noise = room_noise.get_noise_3d(p.x, p.y, p.z)
					if noise > 0.0:
						var dir = Vector3.UP if dy == -room_size else Vector3.DOWN
						var height = clamp((noise+1) * (room_size/4), 0, room_size / 2)
						create_spikes(p, dir, height)

func _random_direction():
	var d = Vector3(randf_range(-1, 1), randf_range(-0.6, -0.3), randf_range(-1, 1))
	return d.normalized()

func _is_not_edge(pos: Vector3):
	return pos.x > 1 and pos.x < grid_size - 1 \
		and pos.y > 1 and pos.y < grid_size \
		and pos.z > 1 and pos.z < grid_size - 1

func _has_reached_border(p):
	var limit = _grid_limit()
	return p.x <= 0 or p.x >= limit \
		or p.y <= 0 or p.y >= limit \
		or p.z <= 0 or p.z >= limit

func _limit_inside_grid(p):
	var limit = _grid_limit()
	p.x = clamp(p.x, 0, limit)
	p.y = clamp(p.y, 0, limit)
	p.z = clamp(p.z, 0, limit)

func _grid_limit():
	return grid_size - worm_radius / 2.0
