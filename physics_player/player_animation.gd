class_name PlayerAnimation
extends AnimationTree

const ATTACK = "parameters/Attack/request"
const RUN = "parameters/Run/blend_position"

func update(forward: Vector3, vel: Vector3):
	var angle = forward.angle_to(vel)
	var dir = Vector3.RIGHT.rotated(Vector3.UP, angle) * vel.length()
	set(RUN, Vector2(dir.x, dir.z))

func attack():
	set(ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
