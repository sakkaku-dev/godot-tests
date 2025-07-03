class_name BarbarianAnimation
extends AnimationTree

@export var hit_box: HitBox
@export var attack_timer: Timer

@export var spin_hit: HitBox
@export var spin_timer: Timer

const ATTACK = "parameters/Attack/request"
const SPIN = "parameters/Spin/blend_amount"
const RUN = "parameters/Run/blend_position"

func _ready() -> void:
	attack_timer.timeout.connect(func(): hit_box.do_hit())
	spin_timer.timeout.connect(func(): spin_hit.do_hit())

func update(forward: Vector3, vel: Vector3):
	var angle = forward.angle_to(vel)
	var dir = Vector3.RIGHT.rotated(Vector3.UP, angle) * vel.length()
	set(RUN, Vector2(dir.x, dir.z))

func attack():
	set(ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	attack_timer.start()

func set_is_spinning(spin: bool):
	set(SPIN, 1 if spin else 0)
	if spin:
		spin_timer.start()
	else:
		spin_timer.stop()
