extends VBoxContainer

@export var hand: Hand
@onready var label: Label = $Label

func _ready() -> void:
	hand.items_updated.connect(func(): _update())
	_update()
	
func _update():
	label.text = ""
	for item in hand.items:
		label.text += "%s: %s" % [item, hand.items[item]]
