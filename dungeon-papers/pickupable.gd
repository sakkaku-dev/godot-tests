class_name Pickupable
extends RigidBody3D

@export var type: GridItem.Type
@export var interactable: Interactable3D

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

func _on_interacted(hand: Hand3D) -> void:
	hand.grab_item(type, true)
	queue_free()
