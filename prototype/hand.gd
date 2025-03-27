class_name Hand
extends Area3D

signal items_updated()

var items := {}

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()

func interact():
	for area in get_overlapping_areas():
		var item = area.interact()
		_pickup_item(item)
		break

func _pickup_item(item):
	if item == null: return
	
	if not item in items:
		items[item] = 0
	
	items[item] += 1
	items_updated.emit()
