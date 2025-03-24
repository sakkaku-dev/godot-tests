class_name Stopwatch

var title := ""
var start_time := 0.0
var time := 0.0

func start(x):
	time = Time.get_ticks_msec()
	start_time = time
	title = x

func print_lap(msg: String, t = time):
	var elapsed = (Time.get_ticks_msec() - t) / 1000.0
	print("%s: %ss" % [msg, elapsed])
	time = Time.get_ticks_msec()

func finish():
	print_lap(title, start_time)
