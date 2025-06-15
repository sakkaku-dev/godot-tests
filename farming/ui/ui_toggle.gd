extends TextureButton

@export var control: Control

func _ready() -> void:
	control.hide()
	pressed.connect(func(): control.visible = not control.visible)
