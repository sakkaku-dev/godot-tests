class_name MazeMap
extends Node3D

const CELL_SIZE = 2.0  # Size of each cell in the 3D space
const WALL_HEIGHT = 3.0

@export var maze: Maze

# References to the meshes we'll instance
var wall_mesh: BoxMesh
var floor_mesh: BoxMesh

func generate():
	# Create the basic meshes
	wall_mesh = BoxMesh.new()
	wall_mesh.size = Vector3(CELL_SIZE, WALL_HEIGHT, CELL_SIZE)
	
	floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(CELL_SIZE, 0.1, CELL_SIZE)
	
	# Get reference to the Maze node and wait for it to generate
	await get_tree().create_timer(0.1).timeout
	if maze:
		create_3d_maze(maze.grid)

func create_3d_maze(grid):
	# Create a parent node for all maze elements
	var maze_parent = Node3D.new()
	add_child(maze_parent)
	
	# Create the floor
	var floor_parent = Node3D.new()
	maze_parent.add_child(floor_parent)
	
	# Create walls
	var walls_parent = Node3D.new()
	maze_parent.add_child(walls_parent)
	
	for y in range(len(grid)):
		for x in range(len(grid[y])):
			# Convert grid coordinates to 3D world coordinates
			var pos_x = (x - len(grid[y])/2) * CELL_SIZE
			var pos_z = (y - len(grid)/2) * CELL_SIZE
			
			# Create floor tile
			var floor_instance = MeshInstance3D.new()
			floor_instance.mesh = floor_mesh
			floor_instance.position = Vector3(pos_x, -WALL_HEIGHT/2, pos_z)
			floor_parent.add_child(floor_instance)
			
			# Create wall if this is a wall cell
			if grid[y][x] == 1:  # WALL
				var wall_instance = MeshInstance3D.new()
				wall_instance.mesh = wall_mesh
				wall_instance.position = Vector3(pos_x, 0, pos_z)
				walls_parent.add_child(wall_instance)
	
	# Add collision shapes
	add_collision_shapes(walls_parent)
	add_collision_shapes(floor_parent)

	# Add a ceiling collision to prevent flying over walls
	var ceiling_body = StaticBody3D.new()
	maze_parent.add_child(ceiling_body)
	
	var ceiling_collision = CollisionShape3D.new()
	ceiling_body.add_child(ceiling_collision)
	
	var ceiling_shape = BoxShape3D.new()
	# Make shape span the full grid width/height and be relatively thin
	ceiling_shape.size = Vector3(
		CELL_SIZE * len(grid[0]), 
		0.1,  # Thin collision plane
		CELL_SIZE * len(grid)
	)
	ceiling_collision.shape = ceiling_shape
	
	# Position at top of walls
	ceiling_collision.position = Vector3(0, WALL_HEIGHT - WALL_HEIGHT/2, 0)

	# Add visible ceiling mesh
	var ceiling_mesh_instance = MeshInstance3D.new()
	ceiling_mesh_instance.mesh = floor_mesh # Reuse floor mesh since it's a flat surface
	# Scale to match collision shape size
	ceiling_mesh_instance.scale = Vector3(
		len(grid[0]),
		1,
		len(grid)
	)
	ceiling_collision.add_child(ceiling_mesh_instance)

func add_collision_shapes(parent: Node3D):
	for child in parent.get_children():
		if child is MeshInstance3D:
			var collision_shape = CollisionShape3D.new()
			var shape = BoxShape3D.new()
			shape.size = child.mesh.size
			collision_shape.shape = shape
			
			var static_body = StaticBody3D.new()
			static_body.add_child(collision_shape)
			child.add_child(static_body)

func get_cell_position(x: int, y: int) -> Vector3:
	var pos_x = (x - maze.WIDTH/2) * CELL_SIZE
	var pos_z = (y - maze.HEIGHT/2) * CELL_SIZE
	return Vector3(pos_x, 0, pos_z)
