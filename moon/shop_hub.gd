class_name ShopHub
extends Node3D

@export var interactable: Interactable

func _ready() -> void:
    interactable.interacted.connect(_on_interacted)

func _on_interacted(hand: Hand):
    pass