extends Node

@export var day_timer: Timer
@export var depot: Depot

func _ready():
	day_timer.timeout.connect(_on_day_ended)
	depot.packages_delivered.connect(_on_packages_delivered)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight") and day_timer.is_stopped():
		start_day()

func _on_packages_delivered():
	day_timer.stop()
	print("All packages delivered")

func _on_day_ended():
	print("Day ended with %s packages left" % depot.packages.size())

func start_day():
	day_timer.start()
	depot.receive_packages(5)
