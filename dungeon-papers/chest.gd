class_name Chest
extends Station

@export var chest_size := 10

var current_items := []

func pick_up(holder: Node3D):
	if DungeonGame.is_prepping():
		pass

func put_item(item: Item):
	current_item = item
	move_item(item, self)
	item.position = item_position.position
	item.disable_pickup()
	is_working = automatic and can_do_work()
	return true
