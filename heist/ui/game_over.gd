class_name Gameover
extends Control

@export var restart_btn: Button

func _ready() -> void:
	visibility_changed.connect(func(): _on_shown())
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())

func _on_shown():
	if not visible: return

	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
