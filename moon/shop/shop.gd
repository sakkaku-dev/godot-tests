class_name Shop
extends Control

@export var placement: PlacementRayCast
@export var container: Control
@export var shop_item_scene: PackedScene
@export var items: Array[ShopItemResource] = []

var logger = NetworkLogger.new("Shop")

func _ready() -> void:
	hide()
	set_process_unhandled_input(is_multiplayer_authority())
	
	for item in items:
		var shop_item = shop_item_scene.instantiate() as ShopItem
		shop_item.set_item(item)
		shop_item.pressed.connect(func(): _on_item_pressed(item))
		container.add_child(shop_item)
		
	placement.placed.connect(func(item: ShopItemResource, pos: Vector3):
		var node = item.scene.instantiate()
		node.position = pos
		get_tree().current_scene.add_child(node)
		placement.cancel_placement()
		logger.info("Item %s placed at %s" % [item.name, pos])
	)
	
	visibility_changed.connect(func():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not visible else Input.MOUSE_MODE_VISIBLE
	)

func _on_item_pressed(item: ShopItemResource) -> void:
	logger.info("Placing item %s" % item.name)
	hide()
	placement.show_placement(item)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shop"):
		visible = not visible
	elif event.is_action_pressed("ui_cancel"):
		if placement.has_placement_object():
			placement.cancel_placement()
			show()
		else:
			hide()
	elif event.is_action_pressed("main_action") and placement.has_placement_object():
		placement.place_object()
