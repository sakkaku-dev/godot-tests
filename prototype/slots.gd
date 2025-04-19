extends Node3D

@export var label: Label

var slot := -1:
	set(v):
		var prev_item = get_item()
		if prev_item:
			prev_item.hide()
		
		slot = v
		label.text = "Slot %s" % v

		var curr_item = get_item()
		if curr_item:
			curr_item.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("main_action"):
		var item = get_item()
		if item and item.has_method("fire"):
			item.fire()
	elif event.is_action_pressed("slot_1"):
		slot = 0 if slot != 0 else -1
	elif event.is_action_pressed("slot_2"):
		slot = 1 if slot != 1 else -1
	elif event.is_action_pressed("slot_3"):
		slot = 2 if slot != 2 else -1

func get_item():
	if slot < 0 or slot >= get_child_count():
		return null
		
	return get_child(slot)
