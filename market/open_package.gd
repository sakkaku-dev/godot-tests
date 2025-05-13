class_name OpenPackage
extends RigidBody3D

@export var scene: PackedScene
@export var interactable: Interactable

func _ready() -> void:
	interactable.interacted.connect(func(p: PhysicsPlayer):
		var node = scene.instantiate() as Item
		p.pickup(node)
		queue_free()
	)
