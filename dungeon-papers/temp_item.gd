class_name TempItem
extends Node3D

enum Type {
	METAL,
	HOT_METAL,

	LEATHER,
	CUT_LEATHER,

	POTION,
	ROBE,
	STAFF,

	SWORD,
	SHIELD,
	ARMOR,

	CROSSBOW,
	QUIVER,
	ARROW,
}

@export var type: Type
@export var interactable: Interactable3D

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

func _on_interacted(hand: Hand3D):
	hand.grab_item(type)
