extends TextureButton

@onready var highlight: TextureRect = $Highlight

func _ready() -> void:
	highlight.hide()
	mouse_entered.connect(func(): highlight.show())
	mouse_exited.connect(func(): highlight.hide())

func set_disable(disable: bool):
	disabled = disable
	modulate = Color.LIGHT_GRAY if disable else Color.WHITE
