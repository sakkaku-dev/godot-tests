class_name Interactable
extends Area2D

signal interacted()

var is_hover := false

func _ready() -> void:
	mouse_entered.connect(func(): is_hover = true)
	mouse_exited.connect(func(): is_hover = false)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action") and is_hover:
		interacted.emit()
		get_viewport().set_input_as_handled()
