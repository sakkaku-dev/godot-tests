class_name Depot
extends Node3D

signal packages_delivered()

@export var destinations: Array[Destination] = []
@export var package_types: Array[PackedScene] = []

var packages := []

func receive_packages(count: int) -> void:
	print("Received %d packages" % count)

	for i in range(count):
		var package = package_types.pick_random().instantiate()
		package.destination = destinations.pick_random()
		package.position = Vector3(randf_range(-3, 3), 3, randf_range(-3, 3))
		packages.append(package)
		add_child(package)
		print("Package %d added at position %s" % [i, package.position])
		
		package.delivered.connect(func():)

func _on_package_delivered(pkg: Package):
	if not pkg in packages: return
	
	packages.erase(pkg)
	if packages.is_empty():
		packages_delivered.emit()
