class_name KnightAnimation
extends AnimationTree

@export var hit_box: HitBox
@export var attack_timer: Timer

@export var shield_hit: HitBox
@export var shield_timer: Timer

const ATTACK = "parameters/Attack/request"
const RUN = "parameters/Run/blend_position"
const BLOCK = "parameters/Block/blend_amount"
const BLOCK_ATTACK = "parameters/BlockAttack/request"

func _ready() -> void:
	attack_timer.timeout.connect(func(): hit_box.do_hit())
	shield_timer.timeout.connect(func(): shield_hit.do_hit())

func set_blocking(block = false):
	set(BLOCK, 1 if block else 0)

func update(forward: Vector3, vel: Vector3):
	var angle = forward.angle_to(vel)
	var dir = Vector3.RIGHT.rotated(Vector3.UP, angle) * vel.length()
	set(RUN, Vector2(dir.x, dir.z))

func attack():
	set(ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	attack_timer.start()

func block_attack():
	set(BLOCK_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	shield_timer.start()
