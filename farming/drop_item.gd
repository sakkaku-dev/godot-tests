class_name DropItem
extends Area2D

@export var item: ItemResource
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.texture = item.texture
