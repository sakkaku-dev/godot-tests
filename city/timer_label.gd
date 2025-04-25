extends Label

@export var timer: Timer

func _process(delta: float) -> void:
	if timer.is_stopped(): return
	
	text = "%.0fs" % timer.time_left
