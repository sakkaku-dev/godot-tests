extends Node3D

@export var price_per_item := 10
@export var interactable: Interactable
@export var label_3d: Label3D

var logger := NetworkLogger.new("Extractor")
var money := 0:
	set(v):
		money = v
		label_3d.text = "%s" % money

func _ready() -> void:
	interactable.interacted.connect(func(hand: Hand):
		var item = ""
		var amount = hand.take_items(item)
		
		if amount > 0:
			var earn = price_per_item * amount
			money += earn
			logger.info("Removing %s of %s, earning %s" % [amount, item, earn])
	)
