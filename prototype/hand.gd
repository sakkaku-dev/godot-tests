class_name Hand
extends Area3D

signal items_updated()

@export var player: Player

var items := {}
var zip_follow: PathFollow3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if not remove_zip():
			interact()

func remove_zip():
	if zip_follow:
		zip_follow.queue_free()
		zip_follow = null
		return true
	
	return false

func interact():
	for area in get_overlapping_areas():
		var item = area.interact()
		if item is PathFollow3D:
			_add_zip_line(item)
		else:
			_pickup_item(item)
		break

func _add_zip_line(item: PathFollow3D):
	zip_follow = item
	var remote = zip_follow.get_child(0) as RemoteTransform3D
	remote.remote_path = remote.get_path_to(player)

func _pickup_item(item):
	if item == null: return
	
	if not item in items:
		items[item] = 0
	
	items[item] += 1
	items_updated.emit()

func get_zip_direction():
	if not zip_follow: return Vector3.ZERO
	
	var path = zip_follow.get_parent() as Path3D
	var curve = path.curve
	if curve.point_count != 2:
		return Vector3.ZERO
	
	var dir = path.to_global(curve.get_point_position(1)) - path.to_global(curve.get_point_position(0))
	return dir.normalized()
