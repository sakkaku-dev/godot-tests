class_name ResourceInteractable
extends Interactable

var chunk_key := Vector2(-1, -1)
var resource_id := -1
var item := ""

func interact(actor):
	super.interact(actor)
	if resource_id >= 0:
		ResourceManager.remove_resource(chunk_key, resource_id)
	queue_free()
	return item
