class_name InventoryUI
extends GridContainer

signal toggle_toolbar(item: ItemResource)

@export var toolbar: Toolbar
@export var inventory: Inventory
@export var slot_scene: PackedScene

func _ready() -> void:
	columns = inventory.size.x
	for x in inventory.size.x:
		for y in inventory.size.y:
			var slot = slot_scene.instantiate() as ItemSlot
			slot.secondary_action.connect(func():
				toolbar.toggle_toolbar_item(slot.item)
				slot.is_toolbar = toolbar.has_item(slot.item)
			)
			add_child(slot)

	inventory.inventory_updated.connect(func(slots: Array):
		for s in slots:
			get_child(s).item = inventory.get_item(s)
			
		for s in toolbar.get_slots():
			s.item = s.item
	)
