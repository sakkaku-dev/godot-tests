class_name Rogue
extends PlayerClass

@export var anim: RogueAnimation

func _on_primary_pressed():
	anim.attack()

func _on_secondary_pressed():
	anim.set_range_attack(true)
	player.speed_multiplier = speed * 0.5

func _on_secondary_released():
	anim.set_range_attack(false)
	player.speed_multiplier = speed

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
