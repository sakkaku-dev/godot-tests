class_name Block
extends Node3D

@export var res: BlockResource
@onready var hurt_box: HurtBox = $HurtBox

func _ready() -> void:
	hurt_box.health = res.health
	hurt_box.max_health = res.health
	hurt_box.died.connect(func(): queue_free())

	if res.scene:
		var node = res.scene.instantiate()
		add_child(node)
