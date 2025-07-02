class_name Knight
extends Node

@export var anim: KnightAnimation
@onready var player: PhysicsPlayer = owner

var is_blocking := false:
	set(v):
		is_blocking = v
		player.is_aiming = v
		anim.set_blocking(is_blocking)

func _ready() -> void:
	is_blocking = false
	player.player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary"):
			if not is_blocking:
				anim.attack()
			else:
				anim.block_attack()
		elif ev.is_action_pressed("secondary"):
			is_blocking = true
	)
	player.player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("secondary"):
			is_blocking = false
	)

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
