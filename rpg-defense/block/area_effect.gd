class_name AreaEffect
extends Area3D

@export var field := ""
@export var amount := 0.0
@export var effect_time := 1.0
@onready var fire_rate_timer: Timer = $FireRateTimer

func _ready() -> void:
	body_entered.connect(func(_b): fire_rate_timer.start())
	body_exited.connect(func(_b):
		if get_overlapping_bodies().is_empty():
			fire_rate_timer.stop()
	)
	fire_rate_timer.timeout.connect(func(): apply())
	
func apply():
	for b in get_overlapping_bodies():
		if b is PhysicsCharacter and b.slow_effect:
			b.get(field).apply(amount, effect_time)
