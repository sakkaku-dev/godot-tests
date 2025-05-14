class_name ItemSlot
extends Control

signal count_changed()

@export var highlight: Control
@export var price_label: Label
@export var count_label: Label
@export var texture_rect: TextureRect 

var resource: ItemResource:
	set(v):
		resource = v
		count = 0
		price = resource.price
		texture_rect.texture = resource.image

var count := 0:
	set(v):
		count = clamp(v, 0, 99)
		count_label.text = "%s" % count
		count_changed.emit()

var price := 0:
	set(v):
		price = v
		price_label.text = "%s$" % price
		price_label.visible = price > 0

func _ready() -> void:
	highlight.hide()
	modulate = Color.LIGHT_GRAY
	
	mouse_entered.connect(func(): grab_focus())
	focus_entered.connect(func():
		highlight.show()
		modulate = Color.WHITE
	)
	focus_exited.connect(func():
		highlight.hide()
		modulate = Color.LIGHT_GRAY
	)

func _gui_input(event: InputEvent) -> void: 
	if event.is_action_pressed("count_up"):
		count += 1
	elif event.is_action_pressed("count_down"):
		count -= 1

func get_total_price():
	return count * price
