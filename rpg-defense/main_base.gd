class_name MainBase
extends Node3D

signal died()

@export var health := 100:
	set(v):
		health = v
		health_label.text = "%s" % v
		if health <= 0:
			died.emit()

@onready var hurtbox: Area3D = $Hurtbox
@onready var health_label: Label3D = $HealthLabel

func _ready() -> void:
	self.health = health
	hurtbox.body_entered.connect(func(a):
		a.queue_free()
		health -= a.base_damage
	)
