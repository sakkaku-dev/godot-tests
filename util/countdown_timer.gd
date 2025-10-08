class_name CountdownTimer
extends Label

@export var timer: Timer

func _process(_delta: float) -> void:
	if timer.is_stopped():
		hide()
		return

	show()
	var minutes = floor(int(timer.time_left) / 60.0)
	var seconds = int(timer.time_left) % 60
	text = "%02d:%02d" % [minutes, seconds]
