extends Node3D

@export var player_scene: PackedScene

@onready var maze: Maze = $Maze
@onready var maze_map: MazeMap = $MazeMap

func _ready() -> void:
	maze.generate_maze()
	maze_map.generate()

	var pos = maze.get_spawn_position()
	var player = player_scene.instantiate()
	player.position = maze_map.get_cell_position(pos.x, pos.y)
	add_child(player)
