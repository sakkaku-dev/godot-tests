class_name HurtBox
extends Area3D

signal died()
signal knockbacked(dir: Vector3)

@export var max_health := 10.0
@onready var health = max_health:
	set(v):
		health = clamp(v, 0, max_health)
		if health <= 0:
			died.emit()

func hurt(dmg: int):
	health -= dmg

func heal(amount: int):
	health += amount

func knockback(dir: Vector3):
	knockbacked.emit(dir)
