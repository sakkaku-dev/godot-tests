class_name ItemSlot
extends TextureButton

signal main_action()
signal secondary_action()

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
@onready var toolbar_indicator: ColorRect = $ToolbarIndicator

var active := false:
	set(v):
		active = v
		highlight.visible = v

var is_toolbar := false:
	set(v):
		is_toolbar = v
		toolbar_indicator.visible = v

func _ready() -> void:
	self.item = item
	self.active = false
	self.is_toolbar = false
	
	mouse_entered.connect(func(): highlight.show())
	mouse_exited.connect(func():
		if not active:
			highlight.hide()
	)

func is_free():
	return item == null

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		main_action.emit()
	elif event.is_action_pressed("secondary"):
		secondary_action.emit()
