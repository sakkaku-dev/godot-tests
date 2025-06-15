class_name Placeholder
extends Node2D

@onready var tiles: Tiles = get_tree().get_first_node_in_group("tiles")

var type:
	set(v):
		type = v
		visible = v != null

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if not visible: return
	position = tiles.get_current_mouse_position()

func get_node_for_type():
	if type != null and type < get_child_count():
		return get_child(type)
	return null

func do_action():
	var node = get_node_for_type()
	if node and node.has_method("do_action"):
		node.do_action(tiles)

func do_secondary():
	var node = get_node_for_type()
	if node and node.has_method("do_secondary"):
		node.do_secondary(tiles)
