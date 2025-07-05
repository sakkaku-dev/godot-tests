class_name MageAnimation
extends AnimationTree

const ATTACK = "parameters/Attack/request"
const RUN = "parameters/Run/blend_position"
const CASTING = "parameters/Casting/blend_amount"

@export var mage_attack: Projectile
@export var cast_attack: Projectile
@export var firerate_timer: Timer
@export var casting_timer: Timer

var cast_finished := false

func _ready() -> void:
	casting_timer.timeout.connect(func(): cast_finished = true)

func update(forward: Vector3, vel: Vector3):
	var angle = forward.angle_to(vel)
	var dir = Vector3.RIGHT.rotated(Vector3.UP, angle) * vel.length()
	set(RUN, Vector2(dir.x, dir.z))

func attack():
	if cast_finished:
		cast_attack.spawn()
		cast_finished = false
		return

	if not firerate_timer.is_stopped() or not casting_timer.is_stopped(): return
	
	set(ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	mage_attack.spawn()
	firerate_timer.start()

func set_is_casting(casting: bool):
	set(CASTING, 1 if casting else 0)
	if casting:
		casting_timer.start()
	else:
		casting_timer.stop()
