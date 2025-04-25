class_name Package
extends RigidBody3D

signal delivered()

@export var drop_timer: Timer
@export var sprite: Sprite3D

var destination: Destination

func _ready():
	drop_timer.timeout.connect(func():
		print("Package dropped at destination: %s" % destination.name)
		delivered.emit()
		queue_free()
	)
	reset_status()

func pickup():
	destination.highlight()
	freeze = true

func drop():
	destination.unhighlight()
	freeze = false

func start_drop(dest: Destination):
	if destination == dest:
		print("Starting drop of package %s to destination %s" % [name, dest.name])
		drop_timer.start()
		sprite.show()
	else:
		print("Package %s cannot be dropped at destination %s" % [name, dest.name])
		sprite.modulate = Color.RED
		sprite.show()

func stop_drop():
	print("Stopping drop of package %s" % name)
	drop_timer.stop()
	reset_status()

func reset_status():
	sprite.modulate = Color.WHITE
	sprite.hide()
