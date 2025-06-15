extends Interactable

func _ready() -> void:
	super._ready()
	interacted.connect(func(): FarmManager.sleep())
