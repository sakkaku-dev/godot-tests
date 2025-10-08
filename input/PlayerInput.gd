class_name PlayerInput
extends InputReader

signal device_switched()

const Device = {
	KEYBOARD = "Keyboard",
	PLAYSTATION = "PS",
	XBOX = "XBOX",
	STEAM_DECK = "Deck",
}

@export var joypad = false : set = _set_joypad
@export var device_id = 0

var _device := Device.KEYBOARD
var _logger = KumaLog.new("Player")

func _set_joypad(is_joypad: bool):
	joypad = is_joypad
	
	var joy_name = Input.get_joy_name(device_id)
	if joypad:
		_device = _get_simplified_device(joy_name)
	else:
		_device = Device.KEYBOARD
		joypad = false
	
	_logger.debug("Changing device %s to joypad %s and device type %s" % [device_id, joypad, _device])
	device_switched.emit()

func _get_simplified_device(raw_name: String) -> String:
	_logger.debug("Detecting controller type from name: %s" % raw_name)

	var n = raw_name.to_lower()
	if n.contains("xbox") or n.contains("microsoft"):
		return Device.XBOX
	
	if n.contains("ps4") or n.contains("ps5") or n.contains("sony") or n.contains("dualsense") or n.contains("dualshock"):
		return Device.PLAYSTATION
	
	return Device.STEAM_DECK

func get_vector(left: String, right: String, up: String, down: String):
	return Vector2(
		get_action_strength(right) - get_action_strength(left),
		get_action_strength(down) - get_action_strength(up),
	)

func is_player_event(event: InputEvent) -> bool:
	return joypad == is_joypad_event(event) and device_id == event.device

func get_id():
	return "%s-%s" % [device_id, joypad]

func set_for_event(event: InputEvent):
	joypad = is_joypad_event(event)
	device_id = event.device

func set_for_id(id: String):
	var parts = id.split("-")
	if parts.size() < 2: return
	
	device_id = int(parts[0])
	joypad = parts[1] == "true"

static func create_id(ev: InputEvent):
	return "%s-%s" % [ev.device, is_joypad_event(ev)]

static func is_joypad_event(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion

func _unhandled_input(event):
	handle_input(event)

func handle_input(event: InputEvent) -> void:
	if not is_player_event(event):
		return

	super.handle_input(event)
