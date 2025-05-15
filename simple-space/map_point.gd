extends Control

@onready var highlight: TextureRect = $Highlight
@onready var mark_tex: TextureRect = $Mark

func _ready() -> void:
	highlight.hide()
	mark_tex.hide()
	
	mouse_entered.connect(func(): highlight.show())
	mouse_exited.connect(func(): highlight.hide())

func mark():
	mark_tex.show()
	undim()

func unmark():
	mark_tex.hide()
	dim()

func dim():
	modulate = Color.LIGHT_GRAY

func undim():
	modulate = Color.WHITE
