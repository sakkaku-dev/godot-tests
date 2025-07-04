class_name Rogue
extends Node

@export var anim: RogueAnimation
@onready var player: PhysicsPlayer = owner

func _ready() -> void:
	player.player_input.just_pressed.connect(func(ev: InputEvent):
		if ev.is_action_pressed("primary"):
			anim.attack()
		elif ev.is_action_pressed("secondary"):
			anim.set_range_attack(true)
	)
	player.player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("secondary"):
			anim.set_range_attack(false)
	)

func _physics_process(delta: float) -> void:
	anim.update(player.body.basis.z, player.linear_velocity)
