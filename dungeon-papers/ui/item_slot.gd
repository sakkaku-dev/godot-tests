class_name ItemSlot
extends Control

@export var texture: TextureRect

var selected := false:
	set(v):
		selected = v
		modulate = Color.WHITE if v else Color.DIM_GRAY

var item := "":
	set(v):
		item = v
		texture.texture

func _ready() -> void:
	self.selected = selected

func is_empty():
	return item == ""
