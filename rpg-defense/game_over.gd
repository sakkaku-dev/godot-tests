extends Control

@export var restart: Button

func _ready() -> void:
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	visibility_changed.connect(func(): get_tree().paused = visible)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
