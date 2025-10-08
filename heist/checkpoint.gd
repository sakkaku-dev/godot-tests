class_name Checkpoint
extends Marker3D

const GROUP = "Checkpoint"

@export var is_active := false

func _ready() -> void:
	add_to_group(GROUP)
