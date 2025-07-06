class_name Mage
extends PlayerClass

@export var anim: MageAnimation

func _on_primary_pressed():
	anim.attack()

func _on_secondary_pressed():
	anim.set_is_casting(true)
	player.speed_multiplier = 0.0

func _on_secondary_released():
	anim.set_is_casting(false)
	player.speed_multiplier = speed

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
