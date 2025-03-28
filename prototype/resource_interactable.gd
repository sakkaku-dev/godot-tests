class_name ResourceInteractable
extends Interactable

func interact():
	interacted.emit()
	get_parent().queue_free()
	return "Item"
