class_name GridItem
extends Node3D

const GROUP = "GridItem"

const PROCESS_TIMES = {
	#Item.Type.SWORD: 2.0,
	#Item.Type.SHIELD: 2.0,
	#Item.Type.ARMOR: 2.0,
	#Item.Type.CROSSBOW: 2.0,
	#Item.Type.QUIVER: 2.0,
	#Item.Type.ARROW: 2.0,
	#Item.Type.POTION: 1.0,
}

const REQUIRED_ITEMS = {
	#Item.Type.SWORD: [Item.Type.METAL, Item.Type.HOT_METAL],
	#Item.Type.SHIELD: [Item.Type.CUT_LEATHER, Item.Type.HOT_METAL],
}

const SUPPORTED_ITEMS = {
	#Type.MELTER: [Item.Type.METAL],
	#Type.ANVIL: [Item.Type.HOT_METAL],
	#Type.CUTTING: [Item.Type.LEATHER],
	#Type.MIXER: [Item.Type.POTION],
}

enum Type {
	TABLE,
	MELTER,
	ANVIL,
	CUTTING,
	MIXER,
	INGREDIENT,
}

@export var type: Type
@export var interactable: Interactable3D
@export var process_timer: Timer

var is_started := true

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	interactable.released.connect(func(_hand: Hand3D): process_timer.stop())
	process_timer.timeout.connect(func(): _on_process_finished())

func _on_interacted(hand: Hand3D):
	if not is_started:
		hand.grab_grid_item(global_position)
		return
	
	var type = hand.item
	var result_type = SUPPORTED_ITEMS.get(type, [])
	var time = PROCESS_TIMES.get(result_type, 0.0)
	if time > 0:
		process_timer.start(time)
	else:
		_on_process_finished()

func _on_process_finished():
	# interactable.last_hand.grab_item(result_type)
	pass
