class_name PlayerItems
extends Control

@export var day_weather: AnimatedSprite2D
@export var money_label: Label
@export var items_container: Control

var money := 100:
	set(v):
		money = v
		money_label.text = "%s" % money

var items := []

func _ready() -> void:
	update_items()

func add_items(new_items: Array):
	items.append_array(new_items)
	update_items()

func update_items():
	var unique_items = []
	for item in items:
		if not unique_items.has(item):
			unique_items.append(item)
	# unique_items.sort_custom(func(a: ItemResource, b: ItemResource) -> int: return a.name < b.name)
	
	var item_counts = {}
	for item in unique_items:
		item_counts[item] = items.count(item)

	var children = items_container.get_children()
	for i in range(children.size()):
		var slot = children[i] as ItemSlot
		if slot:
			if i >= unique_items.size():
				slot.resource = null
				continue

			var res = unique_items[i]
			slot.resource = res
			slot.count = item_counts[res]
