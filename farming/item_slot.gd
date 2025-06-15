class_name ItemSlot
extends TextureButton

@export var sprite: Sprite2D
@export var count: Label
@export var item: ItemResource = null:
	set(v):
		item = v
		if v:
			sprite.texture = item.texture
			sprite.show()
			if not item.tool:
				count.show()
				count.text = "%s" % item.count
			else:
				count.hide()
		else:
			sprite.hide()
			count.hide()

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
