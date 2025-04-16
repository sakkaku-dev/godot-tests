class_name ItemPickup
extends Interactable

@export var parent: Node3D
@export var type := ShopItemResource.Type.WALKIE_TALKIE

func _ready() -> void:
	interacted.connect(func(hand: Hand): )
