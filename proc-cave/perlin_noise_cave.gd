@tool
extends Node

@export var GRID_SIZE := 128
@export var threshold := 0.6
@export var room_size := 10
@export var min_block_size := 20
@export var second_room_connect_chance := 0.3

@export var grid_map: GridMap
@export var noise: Noise
@export var _generate := false:
	set(v):
		generate()

@export_category("Worm")
@export var worm_step_size := 3
@export var worm_radius := 4.0
@export var turn_noise_scale := 1.0
@export var turn_factor := 0.1

const NEIGHBOR_OFFSETS_6 = [
	Vector3(-1, 0, 0), Vector3(1, 0, 0),  # Left, Right
	Vector3(0, -1, 0), Vector3(0, 1, 0),  # Down, Up
	Vector3(0, 0, -1), Vector3(0, 0, 1)   # Backward, Forward
]
var NEIGHBOR_OFFSETS_26 = []

func _ready():
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			for dz in range(-1, 2):
				if dx != 0 or dy != 0 or dz != 0:
					NEIGHBOR_OFFSETS_26.append(Vector3(dx, dy, dz))

func group_connected_cells():
	var groups = []  # List of groups (each group is a list of cells)
	var visited = []  # Track visited cells

	# Initialize the visited grid
	for x in range(GRID_SIZE):
		visited.append([])
		for y in range(GRID_SIZE):
			visited[x].append([])
			for z in range(GRID_SIZE):
				visited[x][y].append(false)

	# Iterate over each cell in the grid
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			for z in range(GRID_SIZE):
				var p = Vector3(x, y, z)
				if not _is_empty(p) and not visited[x][y][z]:  # Cell is filled and unvisited
					var group = []
					flood_fill(visited, x, y, z, group)
					groups.append(group)

	return groups

func flood_fill(visited, x, y, z, group):
	var stack = [[x, y, z]]
	while stack.size() > 0:
		var cell = stack.pop_back()
		var cx = cell[0]
		var cy = cell[1]
		var cz = cell[2]

		if visited[cx][cy][cz]:
			continue

		visited[cx][cy][cz] = true
		group.append(Vector3(cx, cy, cz))

		for offset in NEIGHBOR_OFFSETS_6:
			var nx = cx + offset.x
			var ny = cy + offset.y
			var nz = cz + offset.z

			if nx >= 0 and nx < GRID_SIZE and ny >= 0 and ny < GRID_SIZE and nz >= 0 and nz < GRID_SIZE:
				if not _is_empty(Vector3(nx, ny, nz)) and not visited[nx][ny][nz]:
					stack.append([nx, ny, nz])
		
func generate():
	grid_map.clear()
	
	#for x in GRID_SIZE:
		#for z in GRID_SIZE:
			#var n = noise.get_noise_2d(x, z)
			#var h = remap(n, -1, 1, 0, max_height)
			#for y in h:
				#grid_map.set_cell_item(Vector3(x, y, z), 0)
	
	carve_out_caves_using_noise()
	var rooms = create_rooms()
	connect_rooms(rooms)

func create_rooms():
	var rooms = []
	var blocks = group_connected_cells()
	
	for block in blocks:
		if block.size() < min_block_size:
			for b in block:
				grid_map.set_cell_item(b, -1)
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
					if _is_not_edge(p): # p.x >= 0 and p.x < GRID_SIZE and p.y >= 0 and p.y < GRID_SIZE and p.z >= 0 and p.z < GRID_SIZE:
						grid_map.set_cell_item(p, 0)
						coords.append(p)
	return coords

func carve_rect(pos, size, height):
	for dx in range(-size, size + 1):
		for dz in range(-size, size + 1):
			for dy in range(-height, 0):
				if (dx ** 2 + dz ** 2) <= size ** 2:
					var p = pos + Vector3(dx, dy, dz)
					if _is_not_edge(p):
						grid_map.set_cell_item(p, 0)

func carve_out_caves_using_noise():
	for x in range(1, GRID_SIZE - 1):
		for y in range(1, GRID_SIZE - 1):
			for z in range(1, GRID_SIZE - 1):
				var noise_value = noise.get_noise_3d(x, y, z)
				var p = Vector3i(x,y,z)
				if noise_value > threshold:
					grid_map.set_cell_item(p, 0)

func apply_cellular_automata(iterations=5):
	for i in range(iterations):
		for x in range(1, GRID_SIZE - 1):
			for y in range(1, GRID_SIZE - 1):
				for z in range(1, GRID_SIZE - 1):
					var p = Vector3(x, y, z)
					var neighbors = count_solid_neighbors(x, y, z)
					if _is_empty(p):
						if neighbors > 12:
							grid_map.set_cell_item(p, 0)
					else: 
						if neighbors < 10:
							grid_map.set_cell_item(p, -1)

func get_chunk_blocks():
	var processed_cells := []
	var groups := []
	
	for x in range(1, GRID_SIZE - 1):
		for y in range(1, GRID_SIZE - 1):
			for z in range(1, GRID_SIZE - 1):
				var p = Vector3(x, y, z)
				if _is_empty(p) or p in processed_cells: continue
				
				var neighbors = get_neighbors_of_neighbors(p)
				groups.append(neighbors)
				processed_cells.append_array(neighbors)
				break
	
	return groups

func get_neighbors_of_neighbors(pos: Vector3):
	var neighbors = get_solid_neighbors(pos.x, pos.y, pos.z)
	var result = []

	for n in neighbors:
		result.append(n)
		result.append_array(get_neighbors_of_neighbors(n))
		
	return result

func count_solid_neighbors(x, y, z):
	return get_solid_neighbors(x, y, z).size()

func get_solid_neighbors(x, y, z):
	var result = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dy == 0 and dz == 0:
					continue
				
				var p = Vector3(x + dx, y + dy, z + dz)
				if not _is_empty(p):
					result.append(p)
	
	return result

func _is_empty(p):
	return grid_map.get_cell_item(p) == -1


func _is_not_edge(pos: Vector3):
	return pos.x > 1 and pos.x < GRID_SIZE - 1 \
		and pos.y > 1 and pos.y < GRID_SIZE - 1 \
		and pos.z > 1 and pos.z < GRID_SIZE - 1
