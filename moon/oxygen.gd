class_name Oxygen
extends Node

signal depleted()

@export var enabled := false
@export var decay_over_time := 0.001
@export var progress_bar: Range

var value := 0.0:
	set(v):
		value = max(v, 0.0)
		
		var diff = progress_bar.max_value - progress_bar.min_value
		progress_bar.value = diff * value
		
		if value <= 0.0:
			depleted.emit()

func _ready() -> void:
	value = 1.0

func _process(delta: float) -> void:
	if not enabled: return
	value -= decay_over_time * delta
