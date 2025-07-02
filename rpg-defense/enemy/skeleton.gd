class_name Skeleton
extends PhysicsCharacter

signal died()

@export var base_damage := 1
@export var move_distance_threshold := 0.25

@onready var animation_tree: SkeletonAnimation = $PlayerAnimation
@onready var hit_box: Area3D = $Body/HitBox
@onready var hurtbox: HurtBox = $Hurtbox
@onready var soft_push: SoftPush = $SoftPush
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@onready var selection_b_2: Node3D = $"selection-b2"

@onready var map: GameMap = get_tree().get_first_node_in_group("map")

var prev_coord
var coord:
	set(v):
		prev_coord = coord
		coord = v
		if map:
			selection_b_2.position = map.map_to_local(coord)

var target: Node3D
var attacking := false

func _ready() -> void:
	navigation_agent_3d.target_position = target.global_position
	selection_b_2.position = map.map_to_local(coord)
	
	hit_box.area_entered.connect(func(_a):
		attacking = true
		animation_tree.attack()
	)
	hit_box.area_exited.connect(func(_a): attacking = not hit_box.get_overlapping_areas().is_empty())
	animation_tree.animation_finished.connect(func(name):
		if "_Attack_" in name and attacking:
			animation_tree.attack()
	)
	hurtbox.died.connect(func():
		died.emit()
		queue_free()
	)
	hurtbox.knockbacked.connect(func(force: Vector3):
		apply_central_impulse(force)
	)

func get_next_moveable_cell():
	var cells = map.get_moveable_neighbors(coord, [prev_coord])
	return get_closest_cell_to_target(cells)

func get_next_blocked_cell():
	var cells = map.get_moveable_neighbors(coord, [prev_coord], [])
	return get_closest_cell_to_target(cells)

func get_closest_cell_to_target(cells: Array):
	var closest_cell = null
	var closest_dist = null
	
	var next_target = navigation_agent_3d.get_next_path_position()
	var next_dir = global_position.direction_to(next_target)

	for cell in cells:
		var cell_pos = map.map_to_local(cell)
		var cell_dir = global_position.direction_to(cell_pos)
		var dot = cell_dir.dot(next_dir)
		
		#var dist = target.global_position.distance_squared_to(cell_pos)
		if closest_cell == null or dot > closest_dist:
			closest_cell = cell
			closest_dist = dot
	
	return closest_cell

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	apply_central_force(soft_push.get_push_force(get_move_dir()))
	animation_tree.update(body.basis.z, linear_velocity)
	
	var dist = global_position.distance_squared_to(get_target_position())
	if dist < move_distance_threshold:
		coord = get_next_moveable_cell()
		if coord == null:
			coord = get_next_blocked_cell()
			if coord == null: # shouldn't be possible, probably..
				print("No valid moveable cell found, staying in place.")

func get_target_position():
	var p = map.map_to_local(coord)
	p.y = global_position.y
	return p

func get_move_dir():
	if not ground_spring_cast.is_grounded() or attacking or coord == null:
		return Vector3.ZERO

	return global_position.direction_to(get_target_position())
