class_name Inventory
extends Node

signal inventory_updated(coords: Array)

@export var size = Vector2i.ONE

var items: Array[ItemResource] = []

func _ready() -> void:
	items.resize(size.x * size.y)

func get_item(slot: int):
	return items[slot]

func get_slot_for_item(item: ItemResource):
	for i in range(items.size()):
		if items[i] == item:
			return i
	
	return -1

func add_item(item: ItemResource) -> bool:
	# First try to stack with existing items
	if item.is_stackable():
		for i in items.size():
			if items[i] and items[i].can_merge_with(item):
				items[i].merge(item)
				inventory_updated.emit([i])
				return true
	
	# Then try to find an empty slot
	for i in items.size():
		if not items[i]:
			items[i] = item
			inventory_updated.emit([i])
			return true
	
	return false

func remove_item(slot: int, amount: int = 1):
	if slot < 0 or slot >= items.size() or not items[slot]:
		return null
	
	var item = items[slot]
	if item.is_stackable():
		item.count -= amount
	else:
		items[slot] = null
	
	inventory_updated.emit([slot])

func move_item(from_slot: int, to_slot: int, is_toolbar: bool = false) -> void:
	#var from_array = items
	#var to_array = items if is_toolbar else toolbar
	#
	#if from_slot < 0 or from_slot >= from_array.size() or to_slot < 0 or to_slot >= to_array.size():
		#return
	#
	#var temp = to_array[to_slot]
	#to_array[to_slot] = from_array[from_slot]
	#from_array[from_slot] = temp
	
	inventory_updated.emit([])
