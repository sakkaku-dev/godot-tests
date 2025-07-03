class_name Barbarian
extends Node

@export var anim: KnightAnimation
@onready var player: PhysicsPlayer = owner

func _ready() -> void:
	player.player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary"):
			anim.attack()
		elif ev.is_action_pressed("secondary"):
			pass
	)
	player.player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("secondary"):
			pass
	)

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
