class_name ShopItemResource
extends Resource

enum Type {
	RADAR,
	WALKIE_TALKIE,
}

@export var name := ""
@export var type := Type.RADAR
@export var scene: PackedScene
