class_name ShopItem
extends TextureButton

@export var icon: TextureRect
@export var label: Label

var shop_item: ShopItemResource

func set_item(item: ShopItemResource):
	shop_item = item
	label.text = item.name
