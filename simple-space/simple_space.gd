extends Node2D

@export var items: PlayerItems
@export var shop: ExpeditionShop
@export var map: ExpeditionMap
@export var day_label: Label
@export var intro_label: Label

@export var start_button: TextureButton
@export var shop_button: TextureButton
@export var weather_button: TextureButton

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var day = 0:
	set(v):
		day = v
		day_label.text = "Day %s" % day

func _ready() -> void:
	_update_map_controls()
	map.marked.connect(func(): _update_map_controls())
	shop_button.pressed.connect(func():
		_sync_shop()
		animation_player.play("shop")
	)
	shop.bought.connect(func(new_items: Array, total_price: int):
		items.money -= total_price
		items.add_items(new_items)
		shop.reset_slots()
		_sync_shop()
	)
	shop.back.connect(func(): animation_player.play_backwards("shop"))

func _update_map_controls():
	intro_label.text = "Plan your trip by clicking
the first point on the left" if map.path.is_empty() else "Plan a path to one of
the right points"
	intro_label.visible = not map.has_finished_marking()
	start_button.visible = map.has_finished_marking()

func _sync_shop():
	shop.current_items = items.items
	shop.current_money = items.money
	shop.update_slots()
