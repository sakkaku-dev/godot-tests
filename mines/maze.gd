class_name Maze
extends Node

# Config
const WIDTH = 31  # Must be odd
const HEIGHT = 31
const WALL = 1
const PATH = 0
const ROOM_CHANCE = 0.3
const EXTRA_CONNECTION_CHANCE = 0.1  # 10% chance to add a loop

var grid = []

func generate_maze():
	# Initialize grid full of walls
	grid = []
	for y in range(HEIGHT):
		grid.append([])
		for x in range(WIDTH):
			grid[y].append(WALL)
	
	# Start from center
	var start_x = WIDTH / 2
	var start_y = HEIGHT / 2
	grid[start_y][start_x] = PATH
	
	# Carve main paths
	carve_maze(start_x, start_y)
	
	# Add rooms and extra connections
	add_rooms()
	add_extra_connections()

func carve_maze(x, y):
	var directions = [
		Vector2(0, -2),  # North
		Vector2(2, 0),    # East
		Vector2(0, 2),    # South
		Vector2(-2, 0)    # West
	]
	directions.shuffle()
	
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		
		if nx > 0 && nx < WIDTH-1 && ny > 0 && ny < HEIGHT-1 && grid[ny][nx] == WALL:
			grid[y + int(dir.y / 2)][x + int(dir.x / 2)] = PATH  # Midpoint
			grid[ny][nx] = PATH
			carve_maze(nx, ny)

func add_rooms():
	for y in range(1, HEIGHT-1, 2):
		for x in range(1, WIDTH-1, 2):
			if grid[y][x] == PATH && is_dead_end(x, y) && randf() < ROOM_CHANCE:
				create_room(x, y)

# New function: Add extra corridors between walls
func add_extra_connections():
	for y in range(1, HEIGHT-1):
		for x in range(1, WIDTH-1):
			# Check if this is a wall between two paths
			if grid[y][x] == WALL:
				var horizontal_path = grid[y][x-1] == PATH && grid[y][x+1] == PATH
				var vertical_path = grid[y-1][x] == PATH && grid[y+1][x] == PATH
				
				# Randomly break the wall to create a loop
				if (horizontal_path || vertical_path) && randf() < EXTRA_CONNECTION_CHANCE:
					grid[y][x] = PATH

func is_dead_end(x, y):
	var path_count = 0
	if y > 0 && grid[y-1][x] == PATH: path_count += 1
	if x < WIDTH-1 && grid[y][x+1] == PATH: path_count += 1
	if y < HEIGHT-1 && grid[y+1][x] == PATH: path_count += 1
	if x > 0 && grid[y][x-1] == PATH: path_count += 1
	return path_count == 1

func create_room(x, y):
	var room_size = 3
	for ry in range(y-1, y+2):
		for rx in range(x-1, x+2):
			if rx >= 0 && ry >= 0 && rx < WIDTH && ry < HEIGHT:
				grid[ry][rx] = PATH

func print_maze():
	var output = ""
	for y in range(HEIGHT):
		for x in range(WIDTH):
			output += "▓" if grid[y][x] == WALL else "·"
		output += "\n"
	print(output)

func get_spawn_position() -> Vector2:
	# Try to find center position first
	var center_x = WIDTH / 2
	var center_y = HEIGHT / 2
	
	# If center is a path, return it
	if grid[center_y][center_x] == PATH:
		return Vector2(center_x, center_y)
	
	# Otherwise, search outward in a spiral pattern for nearest path
	var spiral_size = 1
	
	while spiral_size < max(WIDTH, HEIGHT):
		# Check all positions in current spiral
		for dx in range(-spiral_size, spiral_size + 1):
			for dy in range(-spiral_size, spiral_size + 1):
				var check_x = center_x + dx
				var check_y = center_y + dy
				
				# Check if position is within bounds and is a path
				if check_x >= 0 and check_x < WIDTH and check_y >= 0 and check_y < HEIGHT:
					if grid[check_y][check_x] == PATH:
						return Vector2(check_x, check_y)
		
		spiral_size += 1
	
	# Fallback: return first path found
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if grid[y][x] == PATH:
				return Vector2(x, y)
	
	# If somehow no path exists, return center (shouldn't happen in valid maze)
	return Vector2(center_x, center_y)
