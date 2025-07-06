class_name Knight
extends PlayerClass

@export var anim: KnightAnimation

var is_blocking := false:
	set(v):
		is_blocking = v
		player.is_aiming = v
		anim.set_blocking(is_blocking)

func _on_primary_pressed():
	if not is_blocking:
		anim.attack()
	else:
		anim.block_attack()

func _on_secondary_pressed():
	is_blocking = true
	player.speed_multiplier = speed * 0.5

func _on_secondary_released():
	is_blocking = false
	player.speed_multiplier = speed

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
