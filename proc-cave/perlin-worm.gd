@tool
extends Node3D

@export var grid_size := 50
@export var num_worms := 10
@export var worm_length := 10
@export var worm_step_size := 3
@export var worm_radius := 4.0
@export var noise_scale := 1.0
@export var branch_chance := 0.01
@export var turn_factor := 0.1

@export_category("Rooms")
@export var room_size := 10

@export var noise: Noise
@export var grid_map: GridMap
@export var mesh_instance_3d: MarchingCubes

@export var _generate := false:
	set(v):
		generate()

func generate():
	mesh_instance_3d.init_grid(grid_size)
	grid_map.clear()

	var limit = _grid_limit()
	for i in range(num_worms):
		var pos = Vector3(randf_range(0, limit), grid_size, randf_range(0, limit))
		var dir = _random_direction()
		print("Starting worms %s at %s" % [i, pos])
		generate_branch(pos, dir, worm_length)
	
	#mesh_instance_3d.build_mesh()

func generate_branch(pos, dir, length, depth = 0):
	var coords := []
	for i in range(length):
		var noise_value = noise.get_noise_3d(pos.x * noise_scale, pos.y * noise_scale, pos.z * noise_scale)
		dir += turn_factor * Vector3(noise_value, noise_value, noise_value)
		dir = dir.normalized()

		pos += dir * worm_step_size
		_limit_inside_grid(pos)

		print("Moving to direction %s, arriving at %s" % [dir, pos])
		carve_sphere(pos, worm_radius)
		coords.append(pos)

		if _has_reached_border(pos):
			dir = _new_random_direction_between(dir, -0.6, -0.2)

	# if randf() < branch_chance and depth < 3:
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

func carve_sphere(pos, radius):
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			for dz in range(-radius, radius + 1):
				if (dx**2 + dy**2 + dz**2) <= radius**2:
					var xi = int(pos.x + dx)
					var yi = int(pos.y + dy)
					var zi = int(pos.z + dz)
					if xi > 0 and xi < grid_size-1 and yi > 0 and yi < grid_size-1 and zi > 0 and zi < grid_size-1:
						# var v = noise.get_noise_3d(xi, yi, zi)
						var p = Vector3(xi, yi, zi)
						mesh_instance_3d.set_grid_value(p, 1)
						grid_map.set_cell_item(p, 0)
	
func _random_direction():
	var d = Vector3(randf_range(-1, 1), randf_range(-0.6, -0.3), randf_range(-1, 1))
	return d.normalized()

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
