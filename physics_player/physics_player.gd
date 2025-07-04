class_name PhysicsPlayer
extends PhysicsCharacter

const GROUP = "PLAYER"

enum Type {
	KNIGHT,
	BARBARIAN,
	MAGE,
	ROGUE,
}

signal player_ready()
signal placed_block(res: BlockResource, coord: Vector3i)

const BLOCK = preload("res://rpg-defense/block/block.tres")
const FIRE_TURRET = preload("res://rpg-defense/block/fire_turret.tres")
const ICE_TURRET = preload("res://rpg-defense/block/ice_turret.tres")

var CHARACTER_MENU = Type.values().map(func(x): return {"id": x, "title": Type.keys()[x].to_lower().capitalize()})
var BLOCK_MENU = BlockResource.Type.values().map(func(x): return {"id": x, "title": BlockResource.Type.keys()[x].to_lower().capitalize()})

@export var menu: RadialMenu
@export var player_input: PlayerInput
@export var characters: Node3D

@export_category("Classes")
@export var type := Type.KNIGHT:
	set(v):
		type = v

		for node in [knight, barbarian, mage, rogue]:
			node.process_mode = PROCESS_MODE_DISABLED
		
		for c in characters.get_children():
			c.hide()

		match type:
			Type.KNIGHT: active_class = knight
			Type.BARBARIAN: active_class = barbarian
			Type.MAGE: active_class = mage
			Type.ROGUE: active_class = rogue
		
		active_class.process_mode = PROCESS_MODE_INHERIT
		var active_char = characters.get_node(NodePath(active_class.name))
		active_char.show()

@export var knight: Knight
@export var barbarian: Barbarian
@export var mage: Knight
@export var rogue: Rogue

@onready var placement_cube: Node3D = $PlacementCube
@onready var map: GridMap = get_tree().get_first_node_in_group("map")

var is_aiming := false
var active_class = null

var is_character_select := true:
	set(v):
		is_character_select = v
		if is_character_select:
			menu.set_items(CHARACTER_MENU)
		else:
			menu.set_items(BLOCK_MENU)

var placing_block = null:
	set(v):
		placing_block = v
		placement_cube.visible = placing_block != null

func _enter_tree() -> void:
	set_multiplayer_authority(int(name.split("_")[0]))

func _ready() -> void:
	add_to_group(GROUP)
	placing_block = null
	self.is_character_select = is_character_select
	self.type = type
	
	var is_authority = is_multiplayer_authority()
	set_process_unhandled_input(is_authority)
	set_physics_process(is_authority)
	if not is_authority: return
	
	map.disabled_placement.connect(func():
		if placing_block:
			placing_block = null
			placement_cube.visible = false
	)
	menu.item_selected.connect(func(id, _p):
		if is_character_select:
			type = id
		else:
			placing_block = get_block_resource(id)
	)
	
	var parts = name.split("_")
	player_input.set_for_id(parts[1])
	player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary") and placing_block:
			placed_block.emit(placing_block, map.local_to_map(placement_cube.global_position))
		elif ev.is_action_pressed("secondary") and placing_block:
			placing_block = null
		elif ev.is_action_pressed("shop") and map.can_place_blocks:
			if menu.visible:
				menu.close_menu()
			else:
				var cam = get_viewport().get_camera_3d()
				menu.open_menu(cam.unproject_position(global_position))
				placing_block = null
		elif ev.is_action_pressed("ui_accept"):
			player_ready.emit()
	)

func get_block_resource(id: BlockResource.Type):
	match id:
		BlockResource.Type.BLOCK: return BLOCK
		BlockResource.Type.FIRE: return FIRE_TURRET
		BlockResource.Type.ICE: return ICE_TURRET

func _process(_delta: float) -> void:
	if placing_block:
		var current_coord = map.local_to_map(global_position)
		var forward = Vector3i(body.basis.z.normalized().snappedf(1.0))
		placement_cube.global_position = map.map_to_local(current_coord + forward)

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
