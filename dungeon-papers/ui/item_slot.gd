class_name ItemSlot
extends Control

@export var texture: TextureRect

var selected := false:
	set(v):
		selected = v
		_update()

var item := "":
	set(v):
		item = v
		texture.texture # TODO: show item texture
		_update()

func _ready() -> void:
	self.selected = selected

func is_empty():
	return item == ""

func _update():
	if is_empty():
		modulate = Color.BLACK
	elif selected:
		modulate = Color.WHITE
	else:
		modulate = Color.DIM_GRAY
