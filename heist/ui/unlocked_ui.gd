class_name UnlockedUI
extends FinalScreen

@export var money_label: Label
@export var restart_btn: Button

func _ready() -> void:
	super()
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())

func open(money_in_millions: float):
	money_label.text = "You secured $%d million!" % money_in_millions
	show()
