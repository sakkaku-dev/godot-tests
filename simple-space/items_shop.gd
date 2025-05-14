@tool
class_name ExpeditionShop
extends Control

signal back()
signal bought(total)

@export var items_container: Control
@export var item_slot: PackedScene
@export var items: Array[ItemResource] = []
@export var item_desc_label: Label

@export var money_label: Label
@export var total_label: Label

@export var back_btn: BaseButton
@export var buy_btn: BaseButton

var current_money = 100
var total_price = 0

func _ready() -> void:
	back_btn.pressed.connect(func(): close())
	buy_btn.pressed.connect(func(): bought.emit(total_price))

func _update_money():
	total_price = 0
	for c in items_container.get_children():
		if c is ItemSlot:
			total_price += c.get_total_price()
	
	total_label.text = "Total\n%s$" % total_price
	money_label.text = "Money\n%s$" % (current_money - total_price)
	buy_btn.disabled = total_price > current_money
	buy_btn.modulate = Color.DIM_GRAY if buy_btn.disabled else Color.WHITE

func open():
	add_items()
	_update_money()

func close():
	back.emit()

func add_items():
	for c in items_container.get_children():
		c.queue_free()
	
	var first = null
	for item in items:
		var slot = item_slot.instantiate() as ItemSlot
		items_container.add_child(slot)
		slot.resource = item
		slot.focus_entered.connect(func(): item_desc_label.text = "%s. %s" % [item.name, item.description])
		slot.count_changed.connect(_update_money)

		if first == null:
			first = slot
	
	first.grab_focus()
