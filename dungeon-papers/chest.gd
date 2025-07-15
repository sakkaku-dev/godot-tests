class_name Chest
extends Station

@export var chest_size := 10
@export var chest_ui: Popup3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var opened_by = null:
	set(v):
		if opened_by == v: return
		
		opened_by = v
		if opened_by:
			animation_player.play("open")
		else:
			animation_player.play_backwards("open")

func _ready() -> void:
	chest_ui.selected.connect(func(id): _on_item_selected(id))
	chest_ui.closed.connect(func(): opened_by = null)

func _on_item_selected(id: int):
	var item = chest_ui.remove_item(id)
	if item:
		var scene = DungeonGame.get_item_scene(item)
		var node = scene.instantiate()
		opened_by.pickup_item(node)
		chest_ui.close()

func pick_up(holder: Node3D):
	var hand = holder as Hand3D
	if DungeonGame.is_prepping() and hand and not opened_by:
		opened_by = hand.player
		chest_ui.open_for(opened_by)
		opened_by.reset_inputs()

func put_item(item: Item):
	if not chest_ui.add_item(item.item_name): return false
	item.queue_free()
	return true

func add_items(items: Array[String]):
	for i in items:
		chest_ui.add_item(i)
