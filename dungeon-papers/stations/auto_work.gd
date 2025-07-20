class_name AutoWork
extends CircleTimer

@export var processing_time: float = 2.0

func _ready() -> void:
	timer.timeout.connect(func(): finished.emit())

func item_placed(station: Station):
	if station.has_item_to_work():
		timer.start(processing_time)

func item_removed():
	timer.stop()

func is_working():
	return not timer.is_stopped()
