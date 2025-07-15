class_name Popup3D
extends Control

signal selected(id)
signal closed()

@export var container: Control
@export var sprite: Sprite3D
@export var selected_label: Label

var player_input: PlayerInput
var current_selected := 0:
	set(v):
		current_selected = clamp(v, 0, container.get_child_count() - 1)
		selected_label.text = ""
		
		for i in container.get_child_count():
			var child = container.get_child(i)
			child.selected = i == current_selected
			if child.selected and child.item:
				selected_label.text = child.item

func _ready() -> void:
	sprite.hide()
	focus_entered.connect(func(): sprite.show())
	focus_exited.connect(func(): sprite.hide())

func open_for(player: PhysicsPlayer):
	player_input = player.player_input
	current_selected = 0
	grab_focus()

func _gui_input(event: InputEvent) -> void:
	if player_input.is_player_event(event):
		get_viewport().set_input_as_handled()
		
		if event.is_action_pressed("move_right"):
			current_selected += 1
		elif event.is_action_pressed("move_left"):
			current_selected -= 1
		elif event.is_action_pressed("move_down"):
			current_selected += container.get_child_count() / 2
		elif event.is_action_pressed("move_up"):
			current_selected -= container.get_child_count() / 2
		elif event.is_action_pressed("ui_accept"):
			selected.emit(current_selected)
		elif event.is_action_pressed("ui_cancel"):
			close()

func close():
	get_viewport().gui_release_focus()
	closed.emit()

func add_item(item: String):
	for c in container.get_children():
		var slot = c as ItemSlot
		if slot and slot.is_empty():
			slot.item = item
			return true

	return false

func remove_item(id: int):
	var slot = container.get_child(id) as ItemSlot
	var item = slot.item
	slot.item = ""
	return item
