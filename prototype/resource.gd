extends Node3D

@onready var interactable: Interactable = $Interactable

# Not called with scatter??
func _ready() -> void:
	interactable.interacted.emit(func():
		queue_free()
	)
