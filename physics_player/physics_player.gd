extends PhysicsCharacter

@onready var player_input: PlayerInput = $PlayerInput
@onready var animation_tree: PlayerAnimation = $PlayerAnimation
@onready var hit_box: Area3D = $Body/HitBox

var input_id := ""
var color := Color.WHITE
var is_blocking := false

func _ready() -> void:
	player_input.set_for_id(input_id)
	player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary"):
			animation_tree.attack()
		elif ev.is_action_pressed("secondary"):
			is_blocking = true
	)
	player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("secondary"):
			is_blocking = false
	)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	animation_tree.update(body.basis.z, linear_velocity)

func get_move_dir():
	var motion = player_input.get_vector("move_right", "move_left", "move_down", "move_up")
	var move_dir = Vector3(motion.x, 0, motion.y)
	if move_dir.length() > 1:
		move_dir = move_dir.normalized()
	return move_dir

func get_aim_dir():
	if not is_blocking: return Vector3.ZERO
	
	var aim = player_input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim: return Vector3(aim.x, 0, aim.y)
	
	return _get_mouse_direction()

func _get_mouse_direction():
	var screen_pos = get_viewport().get_camera_3d().unproject_position(body.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos) - PI
	return Vector3.RIGHT.rotated(Vector3.UP, -angle)
