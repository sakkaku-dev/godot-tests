class_name FinalScreen
extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visibility_changed.connect(func(): _on_shown())

func _on_shown():
	if not visible: return

	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE