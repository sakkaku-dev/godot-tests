extends Node2D

@onready var interactable: Interactable = $Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	interactable.interacted.connect(func(): animation_player.play("open"))
