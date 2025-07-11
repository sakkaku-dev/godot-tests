class_name ItemBox
extends Station

@export var item: String = ""
@export var label: Label3D

func _ready() -> void:
	super._ready()
	if label:
		label.text = item

@rpc("any_peer", "call_local", "reliable")
func pick_up(holder: Node3D):
	if not DungeonGame.is_prepping() and current_item == null:
		var item_scene = DungeonGame.get_item_scene(item)
		if item_scene:
			var node = item_scene.instantiate()
			node.pick_up(holder)
			return node
	else:
		return super.pick_up(holder)
