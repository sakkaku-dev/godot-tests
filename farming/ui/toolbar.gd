class_name Toolbar
extends Control

signal pressed_item(item: ItemResource)

@export var container: Control

func _ready() -> void:
	for c in container.get_children():
		c.pressed.connect(func():
			if c.item:
				pressed_item.emit(c.item)
		)

func update_active(item: ItemResource):
	for c in container.get_children():
		c.active = c.item == item and item != null

func toggle_toolbar_item(item: ItemResource):
	var first_free = null
	
	for c in container.get_children():
		if c is ItemSlot:
			if c.item == item:
				c.item = null
				return
			if c.item == null and first_free == null:
				first_free = c
	
	if first_free:
		first_free.item = item

func has_item(item: ItemResource):
	for c in container.get_children():
		if c is ItemSlot and c.item == item:
			return true
	return false

func get_slots():
	return container.get_children()
