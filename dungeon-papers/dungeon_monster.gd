class_name DungeonMonster
extends Node3D

const GROUP = "Monster"

enum Type {
	SKELETON,
	GOBLIN,
	SLIME,
	OGRE,
	DRAGON,
}

var type: Type
#var items: Array[Item.Type] = []

@export var interactable: Interactable3D

func _ready() -> void:
	add_to_group(GROUP)
	#interactable.interacted.connect(func(hand: Hand3D): items.append(hand.take_item()))
