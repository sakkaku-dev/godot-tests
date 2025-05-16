class_name ExpeditionShop
extends Control

signal back()
signal bought(items: Array, total_price: int)

@export var back_btn: BaseButton
@export var shop_view: Control
@export var weather_view: Control

@export_category("Weather")
@export var weather_scene: PackedScene
@export var weather_container: Control
@export var weather_forecast_count := 5

@export_category("Shop")
@export var max_items := 5
@export var items_container: Control
@export var item_slot: PackedScene
@export var items: Array[ItemResource] = []
@export var item_desc_label: Label
@export var money_label: Label
@export var total_label: Label
@export var buy_btn: BaseButton
@export var buy_sound: AudioStreamPlayer

var inflation := 1.0
var current_items := []
var current_money := 100

# Calculated
var total_price := 0
var buying_items := []

func _ready() -> void:
	back_btn.pressed.connect(func(): close())
	buy_btn.pressed.connect(func():
		buy_sound.play()
		bought.emit(buying_items, total_price)
	)

func reset_slots():
	for c in items_container.get_children():
		if c is ItemSlot:
			c.reset()

func update_slots():
	total_price = 0
	buying_items.clear()
	for c in items_container.get_children():
		if c is ItemSlot:
			c.count = current_items.count(c.resource)
			total_price += c.get_total_price()
			for i in range(c.add_count):
				buying_items.append(c.resource)
	
	total_label.text = "Total\n%s$" % total_price
	money_label.text = "Money\n%s$" % (current_money - total_price)
	buy_btn.set_disable(total_price > current_money)

	if _current_unique_items_count() >= max_items:
		for c in items_container.get_children():
			if c is ItemSlot and c.count == 0 and c.add_count == 0:
				c.disable()
	else:
		for c in items_container.get_children():
			if c is ItemSlot:
				c.enable()

func _current_unique_items_count():
	var unique_items = []
	for item in current_items:
		if not unique_items.has(item):
			unique_items.append(item)
	for item in buying_items:
		if not unique_items.has(item):
			unique_items.append(item)
	return unique_items.size()

func open_shop(inf: float):
	inflation = inf
	add_items()
	update_slots()
	_show_view(shop_view)

func open_weather(current_day: float, weather_fn: Callable):
	for c in weather_container.get_children():
		c.queue_free()
	
	for i in range(weather_forecast_count):
		var node = weather_scene.instantiate()
		node.day = current_day + i + 1
		node.weather = weather_fn.call(node.day)
		weather_container.add_child(node)
	
	_show_view(weather_view)

func _show_view(view: Control):
	for x in [shop_view, weather_view]:
		x.hide()
	view.show()

func close():
	back.emit()

func add_items():
	for c in items_container.get_children():
		c.queue_free()
	
	var first = null
	for item in items:
		var slot = item_slot.instantiate() as ItemSlot
		items_container.add_child(slot)
		slot.inflation = inflation
		slot.resource = item
		slot.count = current_items.count(item)
		slot.focus_entered.connect(func(): item_desc_label.text = "%s" % [item.description])
		slot.count_changed.connect(update_slots)

		if first == null:
			first = slot
	
	first.grab_focus()
