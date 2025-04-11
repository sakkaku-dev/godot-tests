extends CanvasLayer

func _ready() -> void:
	if not is_multiplayer_authority():
		queue_free()
