class_name Oxygen
extends Node

signal changed()
signal depleted()
signal out_of_oxygen()
signal recovered()

@export var enabled := false
@export var decay_over_time := 0.001
@export var timer: Timer

var is_depleted := false

var value := 0.0:
	set(v):
		value = max(v, 0.0)
		changed.emit()
		
		if value > 0 and is_depleted:
			is_depleted = false
			recovered.emit()
		elif value <= 0.0 and not is_depleted:
			is_depleted = true
			depleted.emit()
			if timer.is_stopped():
				timer.start()

func _ready() -> void:
	value = 1.0
	timer.timeout.connect(func(): out_of_oxygen.emit())

func _process(delta: float) -> void:
	if not enabled: return
	value -= decay_over_time * delta
