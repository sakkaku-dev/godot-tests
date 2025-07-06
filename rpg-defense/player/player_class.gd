class_name PlayerClass
extends Node

@export var health := 100.0
@export var speed := 1.0
@onready var player: PhysicsPlayer = owner

func _ready() -> void:
	player.player_input.just_pressed.connect(func(ev: InputEvent):
		if not is_active(): return
		
		if ev.is_action_pressed("primary"):
			_on_primary_pressed()
		elif ev.is_action_pressed("secondary"):
			_on_secondary_pressed()
	)
	player.player_input.just_released.connect(func(ev: InputEvent):
		if not is_active(): return
		
		if ev.is_action_released("secondary"):
			_on_secondary_released()
	)

func _on_primary_pressed():
	pass

func _on_secondary_pressed():
	pass

func _on_secondary_released():
	pass

func is_active():
	return process_mode != PROCESS_MODE_DISABLED
