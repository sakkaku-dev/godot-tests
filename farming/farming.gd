extends Node2D

func _ready() -> void:
	InputMapper.override_key_inputs({
		"move_up": [KEY_W],
		"move_down": [KEY_S],
		"move_left": [KEY_A],
		"move_right": [KEY_D],
		"interact": [KEY_E],
		"action": [MOUSE_BUTTON_LEFT],
		"secondary": [MOUSE_BUTTON_RIGHT],
	})
