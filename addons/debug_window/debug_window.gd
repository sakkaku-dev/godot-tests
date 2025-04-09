extends CanvasLayer

var actions := {}

@export var line: LineEdit
@export var autocomplete: AutoComplete
@export var debounce_timer: Timer

func _ready() -> void:
	hide()
	
	line.text_changed.connect(func(x):
		if line.text == "":
			hide()
		else:
			debounce_timer.start()
	)
	line.text_submitted.connect(func(x): execute_action())
	debounce_timer.timeout.connect(func():
		var text = line.text.strip_edges()
		if text == "" or text[text.length() - 1] == " ":
			return
		
		var suggests = actions.keys().filter(func(a): return a.begins_with(text))
		autocomplete.show_tags(suggests)
	)
	
	visibility_changed.connect(func():
		if visible:
			line.grab_focus()
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var key = event as InputEventKey
		if key.keycode == KEY_ESCAPE and key.ctrl_pressed:
			visible = not visible
	
func add_action(key: String, callback: Callable):
	actions[key] = callback

func execute_action():
	var parts = line.text.strip_edges().split(" ")
	var action = parts[0]
	if not action in actions: return
	
	actions[action].callv(parts.slice(1))
	line.text = ""
	hide()
