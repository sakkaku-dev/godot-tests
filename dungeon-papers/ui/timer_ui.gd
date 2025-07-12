extends Label

@export var timer: Timer

func _process(_d: float):
	if timer.is_stopped():
		text = "00:00"
		hide()
	else:
		var time_left = timer.time_left
		var minutes = int(time_left / 60)
		var seconds = int(time_left) % 60
		text = "%02d:%02d" % [minutes, seconds]
		show()
