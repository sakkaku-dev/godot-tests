extends TextureButton

func _ready() -> void:
	mouse_entered.connect(func(): modulate = Color.WHITE)
	mouse_exited.connect(func(): modulate = Color.LIGHT_GRAY)
	modulate = Color.LIGHT_GRAY
