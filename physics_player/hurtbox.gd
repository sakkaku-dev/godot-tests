class_name HurtBox
extends Area3D

signal died()

@export var max_health := 1.0
@onready var health := max_health:
	set(v):
		health = clamp(v, 0, max_health)
		if health <= 0:
			died.emit()

func damage(dmg: float):
	health -= dmg
