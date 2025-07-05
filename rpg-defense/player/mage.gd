class_name Mage
extends Node

@export var anim: MageAnimation
@onready var player: PhysicsPlayer = owner

func _ready() -> void:
	player.player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary"):
			anim.attack()
		elif ev.is_action_pressed("secondary"):
			anim.set_is_casting(true)
	)
	player.player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("secondary"):
			anim.set_is_casting(false)
	)

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
