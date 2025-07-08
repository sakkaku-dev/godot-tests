class_name PhysicsPlayer
extends PhysicsCharacter

signal player_ready()

const GROUP = "PLAYER"

@export var menu: RadialMenu
@export var player_input: PlayerInput
@export var color_ring: ColorRect

var color := Color.WHITE
var is_aiming := false

func _enter_tree() -> void:
	set_multiplayer_authority(int(name.split("_")[0]))

func _ready() -> void:
	add_to_group(GROUP)
	color_ring.color = color
	
	var is_authority = is_multiplayer_authority()
	set_process_unhandled_input(is_authority)
	set_physics_process(is_authority)
	if not is_authority: return
	
	var parts = name.split("_")
	player_input.set_for_id(parts[1])

func get_move_dir():
	if menu and menu.visible: return Vector3.ZERO
	
	var motion = player_input.get_vector("move_right", "move_left", "move_down", "move_up")
	var move_dir = Vector3(motion.x, 0, motion.y)
	if move_dir.length() > 1:
		move_dir = move_dir.normalized()
	return move_dir

func get_aim_dir():
	if menu and menu.visible: return Vector3.ZERO
	if not is_aiming: return Vector3.ZERO
	
	var aim = player_input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim: return Vector3(aim.x, 0, aim.y)
	
	return _get_mouse_direction()

func _get_mouse_direction():
	var screen_pos = get_viewport().get_camera_3d().unproject_position(body.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos) - PI
	return Vector3.RIGHT.rotated(Vector3.UP, -angle)
