class_name TimedTapWork
extends CircleTimer

@export var tap_count := 5
@export var start_delay := 1.0
@export var min_delay := 0.5
@export var max_delay := 2.0
@export var valid_hit_offset := 0.2

var tap_times := []
var hits := []
var current_count := 0

func _ready() -> void:
	timer.timeout.connect(on_timeout)

func on_timeout() -> void:
	current_count += 1
	timer.stop()
	
	if tap_times.size() > 0:
		var delay = tap_times.pop_front()
		timer.start(delay)
	else:
		finished.emit()

func started_work():
	for i in tap_count:
		var delay = randf_range(min_delay, max_delay)
		tap_times.append(delay)
		
	current_count += 1
	timer.start(start_delay)

func stopped_work():
	timer.stop()

func work():
	if hits.size() > current_count: return
	
	var offset = timer.time_left
	hits.append(offset)
	on_timeout()
	print("Hit with offset %s" % offset)
