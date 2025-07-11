class_name Item
extends Area3D

@export var item_name: String = "Item"

var is_held: bool = false

func _ready() -> void:
	collision_layer = 1 << 15

@rpc("any_peer", "call_local", "reliable")
func pick_up(holder: Node3D):
	move_item(self, holder)
	position = Vector3.ZERO
	is_held = true
	return self

@rpc("any_peer", "call_local", "reliable")
func put_down(new_position: Vector3):
	if is_held:
		reparent(get_tree().current_scene)
		position = new_position
		is_held = false

func move_item(item: Node3D, new_parent: Node3D):
	if item.is_inside_tree():
		item.reparent(new_parent)
	else:
		new_parent.add_child(item)
