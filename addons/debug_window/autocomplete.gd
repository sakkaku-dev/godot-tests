class_name AutoComplete
extends Control

signal tag_pressed(tag: String)

@export var container: Control
@export var line: LineEdit

var focused_index: = -1:
	set(v):
		focused_index = clamp(v, 0 if visible else -1, container.get_child_count() - 1)
		_update_focus()

func _ready() -> void :
	hide()
	visibility_changed.connect(func(): focused_index = -1)

func show_tags(tags: Array):
	for c in container.get_children():
		c.queue_free()

	visible = not tags.is_empty()

	for i in tags.size():
		var tag = tags[i]
		var btn = Button.new()
		btn.text = tag
		btn.pressed.connect(func(): autocomplete_tag(tag))
		btn.mouse_entered.connect(func(): focused_index = i)

		container.add_child(btn)

func _input(event: InputEvent) -> void :
	if not visible or container.get_child_count() == 0: return

	if event.is_action_pressed("ui_down"):
		focused_index += 1
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		focused_index -= 1
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		hide()
		line.grab_focus()
		line.caret_column = line.text.length()

		get_viewport().set_input_as_handled()

func _update_focus():
	for i in container.get_child_count():
		var btn = container.get_child(i) as Button
		if focused_index == i:
			btn.grab_focus()

func get_last_search_tag() -> String:
	if line.text.is_empty() or line.text[line.text.length() - 1] == " ":
		return ""

	var txt = line.text.strip_edges()
	var parts = txt.split(" ")
	if parts.size() > 0:
		return parts[parts.size() - 1]
	return ""

func autocomplete_tag(tag: String) -> void :
	var last_tag = get_last_search_tag()
	var search_without_last = line.text.substr(0, line.text.length() - last_tag.length())
	line.text = ("%s %s" % [search_without_last.strip_edges(), tag.strip_edges()]).strip_edges() + " "
	hide()

	line.grab_focus()
	line.caret_column = line.text.length()
