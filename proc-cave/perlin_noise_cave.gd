@tool
extends Node

@export var grid: CaveGrid
@export var _generate := false:
	set(v):
		generate()

@export_category("Cave")
@export var noise: Noise
@export var threshold := 0.6
@export var min_block_size := 20
@export var room_area_scene: PackedScene

@export_category("Worm")
@export var worm_step_size := 3
@export var worm_radius := 4.0
@export var turn_noise_scale := 1.0
@export var turn_factor := 0.1

func generate():
	grid.clear()
	#for c in grid.get_children():
		#c.queue_free()
	
	carve_out_caves_using_noise()
	var rooms = create_rooms()
	connect_rooms(rooms)
	#create_echo_chambers(rooms)
	
func create_echo_chambers(rooms: Array):
	for room in rooms:
		var node = room_area_scene.instantiate() as EchoChamber
		grid.add_child(node)
		node.owner = owner
		
		var global_aabb = AABB(grid.map_to_local(room.position), grid.map_to_local(room.end))
		node.set_aabb(global_aabb)

func group_connected_cells():
	var groups = []  # List of groups (each group is a list of cells)
	var visited = []  # Track visited cells

	# Initialize the visited grid
	for x in range(grid.size):
		visited.append([])
		for y in range(grid.size):
			visited[x].append([])
			for z in range(grid.size):
				visited[x][y].append(false)

	# Iterate over each cell in the grid
	for x in range(grid.size):
		for y in range(grid.size):
			for z in range(grid.size):
				var p = Vector3(x, y, z)
				if not grid.is_empty(p) and not visited[x][y][z]:  # Cell is filled and unvisited
					var group = []
					flood_fill(visited, x, y, z, group)
					groups.append(group)

	return groups

func flood_fill(visited, x, y, z, group):
	var stack = [[x, y, z]]

	while stack.size() > 0:
		var cell = stack.pop_back()
		var c = Vector3(cell[0], cell[1], cell[2])
		var cx = cell[0]
		var cy = cell[1]
		var cz = cell[2]

		if visited[cx][cy][cz]:
			continue

		visited[cx][cy][cz] = true
		group.append(c)

		for offset in CaveGrid.NEIGHBOR_OFFSETS_6:
			var n = c + offset
			if grid.is_within(n):
				if not grid.is_empty(n) and not visited[n.x][n.y][n.z]:
					stack.append([n.x, n.y, n.z])
		
func create_rooms():
	var rooms = []
	var blocks = group_connected_cells()
	
	for block in blocks:
		if block.size() < min_block_size:
			for b in block:
				grid.set_cell_item(b, -1)
			continue

		var bounds = get_used_bounds(block)
		var min_y = block[0]
		for p in block:
			if p.y < min_y.y:
				min_y = p
		
		rooms.append(bounds)
	return rooms
	
func connect_rooms(rooms: Array):
	var coords = rooms.map(func(r): return r.get_center())
	coords.sort_custom(func(a, b): return a.y < b.y)

	for c in coords:
		for other_c in coords:
			if c == other_c: continue
			
			var dist = c.distance_to(other_c)
			if dist < 100:
				generate_path(c, other_c)

	#var curr = coords.pop_front()
	#while coords.size() > 0:
		#var next = coords.pop_front()
		#generate_path(curr, next)
#
		#if randf() < second_room_connect_chance:
			#var further_next = coords[0]
			#generate_path(curr, further_next)
#
		#curr = next

func generate_path(pos, target,  depth = 0):
	var dir = pos.direction_to(target)
	while pos.distance_to(target) > worm_radius:
		# var noise_value = noise.get_noise_3d(pos.x * turn_noise_scale, pos.y * turn_noise_scale, pos.z * turn_noise_scale)
		# dir += turn_factor * Vector3(noise_value, noise_value, noise_value)
		# dir = dir.normalized()

		pos += dir * worm_step_size
		carve_sphere(pos, worm_radius)


func get_used_bounds(block: Array) -> AABB:
	if block.is_empty(): return AABB()

	var min_v = block[0]
	var max_v = block[0]

	for p in block:
		min_v.x = min(min_v.x, p.x)
		min_v.y = min(min_v.y, p.y)
		min_v.z = min(min_v.z, p.z)

		max_v.x = max(max_v.x, p.x)
		max_v.y = max(max_v.y, p.y)
		max_v.z = max(max_v.z, p.z)
	
	var size = max_v - min_v
	return AABB(min_v, size)

func carve_sphere(pos, radius, half = false):
	var coords = []
	for dx in range(-radius, radius + 1):
		var min_y = 0 if half else -radius
		for dy in range(min_y, radius + 1):
			for dz in range(-radius, radius + 1):
				if (dx ** 2 + dy ** 2 + dz ** 2) <= radius ** 2:
					var p = pos + Vector3(dx, dy, dz)
					if grid.is_not_edge(p): # p.x >= 0 and p.x < GRID_SIZE and p.y >= 0 and p.y < GRID_SIZE and p.z >= 0 and p.z < GRID_SIZE:
						grid.set_cell_item(p, 0)
						coords.append(p)
	return coords

func carve_rect(pos, size, height):
	for dx in range(-size, size + 1):
		for dz in range(-size, size + 1):
			for dy in range(-height, 0):
				if (dx ** 2 + dz ** 2) <= size ** 2:
					var p = pos + Vector3(dx, dy, dz)
					if grid.is_not_edge(p):
						grid.set_cell_item(p, 0)

func carve_out_caves_using_noise():
	for x in range(1, grid.size - 1):
		for y in range(1, grid.size - 1):
			for z in range(1, grid.size - 1):
				var noise_value = noise.get_noise_3d(x, y, z)
				var p = Vector3i(x,y,z)
				if noise_value > threshold:
					grid.set_cell_item(p, 0)

func get_chunk_blocks():
	var processed_cells := []
	var groups := []
	
	for x in range(1, grid.size - 1):
		for y in range(1, grid.size - 1):
			for z in range(1, grid.size - 1):
				var p = Vector3(x, y, z)
				if grid.is_empty(p) or p in processed_cells: continue
				
				var neighbors = grid.get_neighbors_of_neighbors(p)
				groups.append(neighbors)
				processed_cells.append_array(neighbors)
				break
	
	return groups
