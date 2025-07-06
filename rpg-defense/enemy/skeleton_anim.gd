class_name SkeletonAnimation
extends AnimationTree

const RUN = "parameters/Run/blend_position"
const DEATH = "parameters/Death/request"
const DEATH_STATE = "parameters/DeathState/blend_amount"

func update(forward: Vector3, vel: Vector3):
	var angle = forward.angle_to(vel)
	var dir = Vector3.RIGHT.rotated(Vector3.UP, angle) * vel.length()
	set(RUN, Vector2(dir.x, dir.z))

func died():
	set(DEATH, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	set(DEATH_STATE, 1)
