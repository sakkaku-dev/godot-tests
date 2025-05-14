extends Node2D

@export var items: PlayerItems
@export var shop: ExpeditionShop
@export var shop_button: TextureButton
@export var weather_button: TextureButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	shop_button.pressed.connect(func(): animation_player.play("shop"))
	shop.back.connect(func(): animation_player.play_backwards("shop"))
