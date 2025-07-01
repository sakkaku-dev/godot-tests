class_name Knight
extends PhysicsPlayer

var is_blocking := false:
	set(v):
		is_blocking = v
		is_aiming = v

func _ready() -> void:
	player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("secondary"):
			is_blocking = false
	)

func on_attack():
	if not is_blocking:
		animation_tree.attack()
	else:
		animation_tree.secondary_attack()

func on_secondary():
	is_blocking = true
