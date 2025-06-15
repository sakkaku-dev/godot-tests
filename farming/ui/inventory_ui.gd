extends GridContainer

@export var inventory: Inventory
@export var slot_scene: PackedScene

func _ready() -> void:
	columns = inventory.size.x
	for x in inventory.size.x:
		for y in inventory.size.y:
			var slot = slot_scene.instantiate()
			add_child(slot)

	inventory.inventory_updated.connect(func(slots: Array):
		for s in slots:
			get_child(s).item = inventory.get_item(s)
	)
