class_name Hand3D
extends Area3D

signal item_changed()
signal grid_item_grabbed(pos)

var is_grid_item := false
var item:
	set(v):
		item = v
		item_changed.emit()

var last_interactable = null

func interact():
	if last_interactable: return

	for area in get_overlapping_areas():
		if not area is Interactable3D: continue
		last_interactable = area
		print(area)
		return area.interact(self)

func released():
	if last_interactable:
		last_interactable.release(self)
		last_interactable = null

func grab_item(i, grid_item = false):
	is_grid_item = grid_item
	item = i

func take_item():
	var i = item
	is_grid_item = false
	item = null
	return i

func grab_grid_item(pos):
	grid_item_grabbed.emit(pos)
