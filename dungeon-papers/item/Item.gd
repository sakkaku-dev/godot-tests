class_name Item
extends Area3D

@export var item_name: String = "Item"

var pickupable := true

func _ready() -> void:
	collision_layer = 1 << 15

@rpc("any_peer", "call_local", "reliable")
func pick_up(holder: Node3D):
	move_item(self, holder)
	position = Vector3.ZERO
	rotation.y = 0
	return self

@rpc("any_peer", "call_local", "reliable")
func put_down(new_position: Vector3):
	reparent(get_tree().current_scene)
	position = new_position

func move_item(item: Node3D, new_parent: Node3D):
	if item.is_inside_tree():
		item.reparent(new_parent)
	else:
		new_parent.add_child(item)

func disable_pickup():
	pickupable = false

func enable_pickup():
	pickupable = false

func is_pickupable():
	return pickupable
