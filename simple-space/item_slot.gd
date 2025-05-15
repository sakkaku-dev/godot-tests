class_name ItemSlot
extends Control

signal count_changed()

@export var highlight: Control
@export var price_label: Label
@export var count_label: Label
@export var texture_rect: TextureRect
@export var add_count_label: Label

@export var read_only := false

var disabled := false:
	set(v):
		disabled = v
		if not read_only:
			modulate = Color.LIGHT_GRAY if disabled else Color.WHITE

var resource: ItemResource:
	set(v):
		resource = v
		count = 0
		price = resource.price if resource and not read_only else 0
		texture_rect.texture = resource.image if resource else null

var add_count := 0:
	set(v):
		add_count = clamp(v, 0, 99 - count)
		add_count_label.text = "+%s" % add_count
		add_count_label.visible = add_count > 0
		count_changed.emit()

var count := 0:
	set(v):
		count = clamp(v, 0, 99)
		count_label.text = "%s" % count
		count_label.visible = resource != null

var price := 0:
	set(v):
		price = v
		price_label.text = "%s$" % price
		price_label.visible = price > 0

func _ready() -> void:
	highlight.hide()
	reset()

	if not read_only:
		modulate = Color.LIGHT_GRAY
	
		mouse_entered.connect(func(): grab_focus())
		focus_entered.connect(func():
			highlight.show()
			if not disabled:
				modulate = Color.WHITE
		)
		focus_exited.connect(func():
			highlight.hide()
			if not disabled:
				modulate = Color.LIGHT_GRAY
		)

func _gui_input(event: InputEvent) -> void:
	if disabled: return
	
	if event.is_action_pressed("count_up"):
		add_count += 1
	elif event.is_action_pressed("count_down"):
		add_count -= 1

func get_total_price():
	return add_count * price

func reset():
	add_count = 0
	count = 0

func disable():
	disabled = true

func enable():
	disabled = false
