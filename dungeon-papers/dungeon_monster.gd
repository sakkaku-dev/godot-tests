class_name DungeonMonster
extends Node3D

signal left()

const GROUP = "Monster"

var type: DungeonGame.Monster

@export var label: Label
@onready var dish: Dish = $Dish

func _ready() -> void:
	add_to_group(GROUP)
	label.text = "%s" % DungeonGame.Monster.keys()[type]

func get_type_string() -> String:
	return DungeonGame.Monster.keys()[type]

func get_items():
	return dish.components
	
func remove():
	left.emit()
	queue_free()
