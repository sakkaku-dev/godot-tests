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

@onready var dish: Dish = $Dish

func _ready() -> void:
	add_to_group(GROUP)

func get_items():
	return dish.components
