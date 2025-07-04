class_name RogueAnimation
extends AnimationTree

const AIM = "parameters/Aim/blend_amount"
const AIM_RELOAD = "parameters/AimReload/request"
const AIM_SHOT = "parameters/AimShot/request"
const ATTACK = "parameters/Attack/request"
const RUN = "parameters/Run/blend_position"

@export var hit_box: HitBox
@export var attack_timer: Timer
@export var attack_timer_2: Timer
@export var ranged_firerate: Timer
@export var arrow: ArrowSpawn

@export_category("Weapons")
@export var knife_1: Node3D
@export var knife_2: Node3D
@export var crossbow: Node3D

var is_ranged := false:
	set(v):
		is_ranged = v
		knife_1.visible = not is_ranged
		knife_2.visible = not is_ranged
		crossbow.visible = is_ranged

func _ready() -> void:
	self.is_ranged = is_ranged
	attack_timer.timeout.connect(func(): hit_box.do_hit())
	attack_timer_2.timeout.connect(func(): hit_box.do_hit())

func update(forward: Vector3, vel: Vector3):
	var angle = forward.angle_to(vel)
	var dir = Vector3.RIGHT.rotated(Vector3.UP, angle) * vel.length()
	set(RUN, Vector2(dir.x, dir.z))

func attack():
	if is_ranged:
		if ranged_firerate.is_stopped():
			set(AIM_SHOT, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			ranged_firerate.start()
			arrow.spawn()
	else:
		set(ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		attack_timer.start()
		attack_timer_2.start()

func set_range_attack(ranged: bool):
	is_ranged = ranged
	set(AIM, 1 if ranged else 0)
