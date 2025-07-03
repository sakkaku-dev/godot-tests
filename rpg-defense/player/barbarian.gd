class_name Barbarian
extends Node

@export var anim: BarbarianAnimation
@onready var player: PhysicsPlayer = owner

func _ready() -> void:
	player.player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary"):
			anim.attack()
		elif ev.is_action_pressed("secondary"):
			anim.set_is_spinning(true)
	)
	player.player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("secondary"):
			anim.set_is_spinning(false)
	)

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
