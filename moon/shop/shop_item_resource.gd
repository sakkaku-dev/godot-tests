class_name ShopItemResource
extends Resource

enum Type {
	RADAR,
}

@export var name := ""
@export var type := Type.RADAR
@export var scene: PackedScene
