class_name HurtBox
extends Area3D

signal died()
signal knockbacked(dir: Vector3)
signal health_changed()

@export var max_health := 10.0:
	set(v):
		max_health = v
		health = max_health

@onready var health = max_health:
	set(v):
		health = clamp(v, 0, max_health)
		health_changed.emit()
		if health <= 0:
			died.emit()

func _ready() -> void:
	self.health = health

func hurt(dmg: int):
	health -= dmg

func heal(amount: int):
	health += amount

func knockback(dir: Vector3):
	knockbacked.emit(dir)
