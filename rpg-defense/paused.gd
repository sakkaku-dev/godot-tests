extends ColorRect

@export var restart_btn: Button
@export var continue_btn: Button

func _ready() -> void:
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
	continue_btn.pressed.connect(func(): hide())
	visibility_changed.connect(func(): get_tree().paused = visible)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
