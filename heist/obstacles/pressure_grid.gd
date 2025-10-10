@tool
class_name PressureGrid
extends Obstacle

const NEIGHBORS = [
	Vector2i(0, 1),  # Up
	Vector2i(1, 0),  # Right
	Vector2i(0, -1), # Down
	Vector2i(-1, 0)  # Left
]

@export var grid_size := Vector2i(4, 4)
@export var cell_size := 1.0
@export var cell_scene: PackedScene
@export var run := false:
	set(v):
		run = v
		if Engine.is_editor_hint() and run:
			_generate()
		elif Engine.is_editor_hint() and not run:
			for child in get_children():
				child.queue_free()

var walkable_path := []
var logger = KumaLog.new("PressureGrid")
var connections := []

func _ready() -> void:
	walkable_path = _generate_path()
	_generate()

func _generate():
	_generate_grid()
	_generate_walls()
	_generate_connection_points()

func _generate_path():
	# Randomly generate a walkable path from the smallest y (z=0) to the largest y (z=grid_size.y-1)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var path = []
	var visited = {}

	# Start at a random x in the first row (z=0)
	var x = rng.randi_range(0, grid_size.x - 1)
	var z = 0
	path.append(Vector2i(x, z))
	visited[Vector2i(x, z)] = true

	var dirs := []

	while z < grid_size.y - 1:
		var options = []
		for n in NEIGHBORS:
			if n.y == -1: continue # Don't go back down

			var count = dirs.count(n)
			var neighbor = Vector2i(x, z) + n
			if not visited.has(neighbor) and _is_in_grid(neighbor) and count < 3:
				options.append(neighbor)

		if options.size() == 0: break

		var next_cell = options[rng.randi_range(0, options.size() - 1)]

		dirs.append(next_cell - Vector2i(x, z))
		if dirs.size() > 3:
			dirs.remove_at(0)

		path.append(next_cell)
		for n in NEIGHBORS:
			var neighbor = Vector2i(x, z) + n
			visited[neighbor] = true

		x = next_cell.x
		z = next_cell.y

	logger.debug("Generated path: %s" % [path])
	return path

func _is_in_grid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func _generate_grid():
	for child in get_children():
		child.queue_free()

	for x in range(grid_size.x):
		for z in range(grid_size.y):
			var cell = cell_scene.instantiate()
			cell.position = Vector3((x - grid_size.x / 2.0) * cell_size + cell_size / 2.0, 0, -(z + 1) * cell_size + cell_size / 2.0)
			cell.entered.connect(func():
				if not Vector2i(x, z) in walkable_path:
					cell.queue_free()
					failed.emit()
			)
			add_child(cell)

func _generate_walls():
	var left_wall = CSGBox3D.new()
	left_wall.use_collision = true
	left_wall.size = Vector3(0.1, 2, grid_size.y * cell_size)
	left_wall.position = Vector3(-grid_size.x * cell_size / 2 - 0.1/2, 1, -grid_size.y * cell_size / 2)
	add_child(left_wall)

	var right_wall = CSGBox3D.new()
	right_wall.use_collision = true
	right_wall.size = Vector3(0.1, 2, grid_size.y * cell_size)
	right_wall.position = Vector3(grid_size.x * cell_size / 2 + 0.1/2, 1, -grid_size.y * cell_size / 2)
	add_child(right_wall)

func _generate_connection_points():
	var end_point = Marker3D.new()
	end_point.name = "EndPoint"
	end_point.position = Vector3(0, 0, -grid_size.y * cell_size)
	add_child(end_point)
	connections = [end_point]

func get_connection_points() -> Array:
	return connections
