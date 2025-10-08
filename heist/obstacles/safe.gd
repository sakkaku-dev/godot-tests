class_name Safe
extends Node3D

signal unlocked()
signal failed()

enum Type {
	BLACK,
	WHITE,
	SMALL,
}

const TYPE_OFFSET = {
	Type.BLACK: 1 << 0,
	Type.WHITE: 1 << 1,
	Type.SMALL: 1 << 2,
}

@export var code_length := 3
@export var max_code := 100
@export var allowed_hint_delta := 0.05
@export var lock_mouse_sensitivity := 0.01

@export var safe_type := Type.BLACK
@export var hint_sound: AudioStreamPlayer
@export var correct_sound: AudioStreamPlayer
@export var open_sound: AudioStreamPlayer
@export var controls: Control
@export var value_label: Label3D
@export var safe_lock_rotator: Node3D
@export var interactable_3d: Interactable3D

var code := []
var seed := 0

var played_hint := false
var is_active := false
var step := 0
var lock_position := 0.0:
	set(v):
		lock_position = _normalize_number(v)
		value_label.text = "%.0f" % int(lock_position)
		safe_lock_rotator.rotation.y = remap(lock_position, 0, max_code, 0, TAU)

var logger := KumaLog.new("Safe")

func _normalize_number(num: float):
	if num > max_code:
		num = num - max_code
	elif num < 0:
		num = max_code - num
	return num

func _ready() -> void:
	_generate_code()

	controls.hide()
	value_label.hide()
	controls.focus_entered.connect(func():
		value_label.show()
		controls.show()
	)
	controls.focus_exited.connect(func():
		interactable_3d.release()
		value_label.hide()
		controls.hide()
	)
	
	interactable_3d.interacted.connect(func(_hand):
		logger.info("Interacted with safe by %s" % _hand)
		controls.grab_focus()
	)
	controls.gui_input.connect(func(ev: InputEvent):
		if ev.is_action_pressed("ui_cancel"):
			get_viewport().gui_release_focus()
		elif ev.is_action_pressed("interact"):
			is_active = true
		elif ev.is_action_released("interact"):
			is_active = false
			check_code()
		
		get_viewport().set_input_as_handled()
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_active:
		lock_position += event.relative.x * lock_mouse_sensitivity
		check_hint()
		get_viewport().set_input_as_handled()

func _unlocked():
	unlocked.emit()
	open_sound.play()
	get_viewport().gui_release_focus()
	logger.info("Safe unlocked")

func _generate_code() -> void:
	code.clear()

	var rng = RandomNumberGenerator.new()
	rng.seed = seed + TYPE_OFFSET[safe_type]
	for i in code_length:
		code.append(rng.randi_range(0, max_code))

	logger.debug("Generated safe code: %s" % [code])

func check_hint():
	var hint_number = get_hint_number(code[step])
	#if lock_position >= hint_number - allowed_hint_delta and lock_position <= hint_number + allowed_hint_delta:
	if int(lock_position) == int(hint_number):
		show_hint()
	else:
		played_hint = false

func show_hint():
	if played_hint: return
	
	hint_sound.play()
	played_hint = true
	# TODO: visual cue too

func check_code():
	if int(lock_position) == code[step]:
		logger.info("Code %s successfully entered" % code[step])
		step += 1
		correct_sound.play()
		if step >= code_length:
			_unlocked()
	else:
		step = 0
		failed.emit()


func get_hint_number(num: float) -> float:
	match safe_type:
		Type.BLACK:
			num = num + 50
		Type.WHITE:
			num = floor(num / 2.0)
		Type.SMALL:
			num = num - 22

	return _normalize_number(num)
