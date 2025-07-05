extends ProgressBar

@export var hurtbox: HurtBox

func _ready() -> void:
	hurtbox.health_changed.connect(_update)
	_update()

func _update():
	if hurtbox.health != null:
		value = (hurtbox.health / hurtbox.max_health) * 100
