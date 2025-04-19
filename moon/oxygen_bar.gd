extends ProgressBar

@export var oxygen: Oxygen

func _ready() -> void:
	var diff = max_value - min_value
	oxygen.changed.connect(func(): value = diff * oxygen.value)
