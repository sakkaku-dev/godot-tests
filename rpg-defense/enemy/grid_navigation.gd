class_name GridNavigation
extends NavigationAgent3D

@export var move_distance_threshold := 0.25
@onready var character = owner
@onready var map: GameMap = get_tree().get_first_node_in_group("map")

var prev_coord
var coord:
	set(v):
		prev_coord = coord
		coord = v
	
func has_target():
	return coord != null

func get_target_grid_position():
	var p = map.map_to_local(coord)
	p.y = character.global_position.y
	return p

func _physics_process(_delta: float) -> void:
	var dist = character.global_position.distance_squared_to(get_target_grid_position())
	if dist < move_distance_threshold:
		coord = get_next_moveable_cell()
		if coord == null:
			coord = get_next_blocked_cell()
			if coord == null: # shouldn't be possible, probably..
				print("No valid moveable cell found, staying in place.")

func get_next_moveable_cell():
	var cells = map.get_moveable_neighbors(coord, [prev_coord])
	return get_closest_cell_to_target(cells)

func get_next_blocked_cell():
	var cells = map.get_moveable_neighbors(coord, [prev_coord], [])
	return get_closest_cell_to_target(cells)

func get_closest_cell_to_target(cells: Array):
	var closest_cell = null
	var closest_dist = null
	
	var next_target = get_next_path_position()
	var next_dir = character.global_position.direction_to(next_target)

	for cell in cells:
		var cell_pos = map.map_to_local(cell)
		var cell_dir = character.global_position.direction_to(cell_pos)
		var dot = cell_dir.dot(next_dir)
		
		#var dist = target.global_position.distance_squared_to(cell_pos)
		if closest_cell == null or dot > closest_dist:
			closest_cell = cell
			closest_dist = dot
	
	return closest_cell
