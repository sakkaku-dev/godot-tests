extends SpotLight3D

func _ready() -> void:
	set_process_unhandled_input(is_multiplayer_authority())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		light_energy = 0 if light_energy > 0 else 1
