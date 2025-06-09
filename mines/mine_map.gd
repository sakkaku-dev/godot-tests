extends GridMap
class_name MineMap

# Scene references for different room types
@export var straight_room: PackedScene
@export var corner_room: PackedScene
@export var t_junction_room: PackedScene
@export var cross_junction_room: PackedScene
@export var dead_end_room: PackedScene

# Generation parameters
@export var grid_size := Vector2i(32, 32)
@export var min_corridor_length := 2
@export var max_corridor_length := 6
@export var dead_end_probability := 0.3

# Internal tracking
var cells := {}  # Dictionary to track placed rooms
var rng := RandomNumberGenerator.new()

enum RoomType {
	STRAIGHT = 0,
	CORNER = 1,
	T_JUNCTION = 2,
	CROSS = 3,
	DEAD_END = 4
}

func _ready():
	rng.randomize()
	generate_mine()

func generate_mine():
	# Start from center
	var start_pos = Vector2i(grid_size.x / 2, grid_size.y / 2)
	generate_path(start_pos, 4)  # Start with 4 possible directions
	
	# Place actual room scenes based on their types
	place_room_scenes()

func generate_path(pos: Vector2i, available_exits: int, depth: int = 0):
	# Prevent infinite recursion
	if depth > 10 or !is_inside_grid(pos) or cells.has(pos):
		return
	
	# Mark current cell as a path (will determine exact type later)
	cells[pos] = RoomType.STRAIGHT  # Default type, will be properly determined later
	
	# Get possible directions for new paths
	var directions = get_valid_directions(pos)
	if directions.is_empty():
		return
	
	# Shuffle directions for randomness
	directions.shuffle()
	
	# Determine how many exits to create (based on available_exits)
	var num_exits = rng.randi_range(1, min(available_exits, directions.size()))
	
	for i in range(num_exits):
		if i >= directions.size():
			break
			
		var dir = directions[i]
		var corridor_length = rng.randi_range(min_corridor_length, max_corridor_length)
		
		# Create corridor
		var current = pos
		for j in range(corridor_length):
			current += dir
			if !is_inside_grid(current) or cells.has(current):
				break
				
			cells[current] = RoomType.STRAIGHT  # Mark corridor cells
			
			# Chance to create a branch with increased depth
			if rng.randf() < 0.2:
				generate_path(current, 3, depth + 1)  # Branch with depth tracking
		
		# End of corridor
		if is_inside_grid(current) and !cells.has(current):
			if rng.randf() < dead_end_probability:
				# Create dead end
				cells[current] = RoomType.DEAD_END
			else:
				# Continue path with fewer available exits and increased depth
				generate_path(current, 3, depth + 1)

func get_valid_directions(pos: Vector2i) -> Array:
	var directions = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]
	
	var valid = []
	for dir in directions:
		var check_pos = pos + dir
		if is_inside_grid(check_pos) and !cells.has(check_pos):
			valid.append(dir)
	
	return valid

func is_inside_grid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func place_room_scenes():
	# First pass: Determine room types based on connections
	for pos in cells:
		var type = determine_room_type(pos)
		cells[pos] = type
	
	# Second pass: Place actual scenes
	for pos in cells:
		place_room(pos, cells[pos])

func determine_room_type(pos: Vector2i) -> int:
	var connections = get_connections(pos)
	var count = connections.size()
	
	match count:
		1:
			return RoomType.DEAD_END
		2:
			if (connections.has(Vector2i.RIGHT) and connections.has(Vector2i.LEFT)) or \
			   (connections.has(Vector2i.UP) and connections.has(Vector2i.DOWN)):
				return RoomType.STRAIGHT
			else:
				return RoomType.CORNER
		3:
			return RoomType.T_JUNCTION
		4:
			return RoomType.CROSS
		_:
			return RoomType.DEAD_END

func get_connections(pos: Vector2i) -> Array:
	var directions = [
		Vector2i.RIGHT,
		Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	
	var connected = []
	for dir in directions:
		var check_pos = pos + dir
		if is_inside_grid(check_pos) and cells.has(check_pos):
			connected.append(dir)
	
	return connected

func place_room(pos: Vector2i, type: int):
	var scene: PackedScene
	var rotation := 0.0
	
	match type:
		RoomType.STRAIGHT:
			scene = straight_room
			# Calculate rotation based on connections
			var connections = get_connections(pos)
			if connections.has(Vector2i.UP) or connections.has(Vector2i.DOWN):
				rotation = PI/2
		RoomType.CORNER:
			scene = corner_room
			# Calculate rotation based on connections
			var connections = get_connections(pos)
			if connections.has(Vector2i.RIGHT) and connections.has(Vector2i.UP):
				rotation = 0
			elif connections.has(Vector2i.UP) and connections.has(Vector2i.LEFT):
				rotation = PI/2
			elif connections.has(Vector2i.LEFT) and connections.has(Vector2i.DOWN):
				rotation = PI
			elif connections.has(Vector2i.DOWN) and connections.has(Vector2i.RIGHT):
				rotation = 3*PI/2
		RoomType.T_JUNCTION:
			scene = t_junction_room
			# Calculate rotation based on the missing connection
			var connections = get_connections(pos)
			if !connections.has(Vector2i.UP):
				rotation = 0
			elif !connections.has(Vector2i.RIGHT):
				rotation = PI/2
			elif !connections.has(Vector2i.DOWN):
				rotation = PI
			elif !connections.has(Vector2i.LEFT):
				rotation = 3*PI/2
		RoomType.CROSS:
			scene = cross_junction_room
		RoomType.DEAD_END:
			scene = dead_end_room
			# Calculate rotation based on the single connection
			var connections = get_connections(pos)
			if connections[0] == Vector2i.LEFT:
				rotation = 0
			elif connections[0] == Vector2i.DOWN:
				rotation = PI/2
			elif connections[0] == Vector2i.RIGHT:
				rotation = PI
			elif connections[0] == Vector2i.UP:
				rotation = 3*PI/2
	
	if scene:
		var instance = scene.instantiate()
		add_child(instance)
		# Assuming each room is 8x8 units (adjust this based on your actual room size)
		instance.position = Vector3(pos.x * 8, 0, pos.y * 8)
		instance.rotation.y = rotation
