class_name PhysicsPlayer
extends PhysicsCharacter

signal placed_block(res: BlockResource, coord: Vector3i)

const BLOCK = preload("res://rpg-defense/block/block.tres")
const FIRE_TURRET = preload("res://rpg-defense/block/fire_turret.tres")
const ICE_TURRET = preload("res://rpg-defense/block/ice_turret.tres")

@export var menu: RadialMenu

@onready var player_input: PlayerInput = $PlayerInput
@onready var animation_tree: PlayerAnimation = $PlayerAnimation
@onready var hit_box: Area3D = $Body/HitBox
@onready var placement_cube: Node3D = $PlacementCube

@onready var map: GridMap = get_tree().get_first_node_in_group("map")

var input_id := ""
var color := Color.WHITE
var is_aiming := false

var placing_block = null:
	set(v):
		placing_block = v
		placement_cube.visible = placing_block != null

func _ready() -> void:
	menu.set_items(BlockResource.Type.values().map(func(x): return {"id": x}))
	menu.item_selected.connect(func(id, _p): placing_block = get_block_resource(id))
	map.disabled_placement.connect(func():
		if placing_block:
			placing_block = null
			placement_cube.visible = false
	)
	
	placing_block = null
	player_input.set_for_id(input_id)
	player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary"):
			if placing_block:
				placed_block.emit(placing_block, map.local_to_map(placement_cube.global_position))
			else:
				on_attack()
		elif ev.is_action_pressed("secondary"):
			if placing_block:
				placing_block = null
			else:
				on_secondary()
		elif ev.is_action_pressed("shop") and map.can_place_blocks:
			if menu.visible:
				menu.close_menu()
			else:
				var cam = get_viewport().get_camera_3d()
				menu.open_menu(cam.unproject_position(global_position))
				placing_block = null
	)

func get_block_resource(id: BlockResource.Type):
	match id:
		BlockResource.Type.BLOCK: return BLOCK
		BlockResource.Type.FIRE: return FIRE_TURRET
		BlockResource.Type.ICE: return ICE_TURRET

func on_attack():
	pass

func on_secondary():
	pass

func _process(_delta: float) -> void:
	if placing_block:
		var current_coord = map.local_to_map(global_position)
		var forward = Vector3i(body.basis.z.normalized().snappedf(1.0))
		placement_cube.global_position = map.map_to_local(current_coord + forward)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	animation_tree.update(body.basis.z, linear_velocity)

func get_move_dir():
	if menu.visible: return Vector3.ZERO
	
	var motion = player_input.get_vector("move_right", "move_left", "move_down", "move_up")
	var move_dir = Vector3(motion.x, 0, motion.y)
	if move_dir.length() > 1:
		move_dir = move_dir.normalized()
	return move_dir

func get_aim_dir():
	if menu.visible: return Vector3.ZERO
	if not is_aiming: return Vector3.ZERO
	
	var aim = player_input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim: return Vector3(aim.x, 0, aim.y)
	
	return _get_mouse_direction()

func _get_mouse_direction():
	var screen_pos = get_viewport().get_camera_3d().unproject_position(body.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos) - PI
	return Vector3.RIGHT.rotated(Vector3.UP, -angle)
