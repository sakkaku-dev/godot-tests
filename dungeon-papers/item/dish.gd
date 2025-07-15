class_name Dish
extends Item

@export var components: Array[String] = []

func put_item(item: Item):
	var item_name = item.item_name
	item.queue_free()
	components.append(item_name)
	return true
