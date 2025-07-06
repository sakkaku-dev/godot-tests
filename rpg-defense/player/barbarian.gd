class_name Barbarian
extends PlayerClass

@export var anim: BarbarianAnimation

func _on_primary_pressed():
	anim.attack()

func _on_secondary_pressed():
	anim.set_is_spinning(true)
	player.speed_multiplier = speed * 0.5

func _on_secondary_released():
	anim.set_is_spinning(false)
	player.speed_multiplier = speed

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
