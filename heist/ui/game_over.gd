class_name Gameover
extends FinalScreen

@export var restart_btn: Button

func _ready() -> void:
	super()
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
