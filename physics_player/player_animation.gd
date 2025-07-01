class_name PlayerAnimation
extends AnimationTree

@export var hit_box: HitBox
@export var attack_timer: Timer

const ATTACK = "parameters/Attack/request"
const SECOND_ATTACK = "parameters/SecondAttack/request"
const RUN = "parameters/Run/blend_position"

func _ready() -> void:
	if attack_timer:
		attack_timer.timeout.connect(func(): hit_box.do_hit())

func update(forward: Vector3, vel: Vector3):
	var angle = forward.angle_to(vel)
	var dir = Vector3.RIGHT.rotated(Vector3.UP, angle) * vel.length()
	set(RUN, Vector2(dir.x, dir.z))

func attack():
	set(ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	attack_timer.start()

func secondary_attack():
	set(SECOND_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	attack_timer.start()
