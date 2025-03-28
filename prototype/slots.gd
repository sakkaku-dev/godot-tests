extends Node3D

@export var label: Label

var slot := -1:
	set(v):
		slot = v
		label.text = "Slot %s" % v

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("main_action"):
		var item = get_item()
		if item:
			item.fire()
	elif event.is_action_pressed("slot_1"):
		slot = 0 if slot != 0 else -1
	elif event.is_action_pressed("slot_2"):
		slot = 1 if slot != 1 else -1
	elif event.is_action_pressed("slot_3"):
		slot = 2 if slot != 2 else -1

func get_item():
	if slot < 0:
		return null
		
	return get_child(slot)
