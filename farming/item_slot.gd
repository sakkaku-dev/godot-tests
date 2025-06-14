class_name ItemSlot
extends TextureButton

@export var sprite: Sprite2D
@export var item: ItemResource = null:
	set(v):
		item = v
		if v:
			sprite.texture = item.texture
			sprite.show()
		else:
			sprite.hide()

@onready var highlight: TextureRect = $Highlight

var active := false:
	set(v):
		active = v
		highlight.visible = v

func _ready() -> void:
	self.item = item
	self.active = false

func is_free():
	return item == null
