class_name ModeSelect
extends Control

const HEIST = preload("uid://dhy7vo82ooo18")

@export var mode_container: Control
@export var infiltrator_btn: Button
@export var hacker_btn: Button

@export_category("Infiltrator")
@export var infiltrator_container: Control
@export var infiltrator_start_btn: Button
@export var infiltrator_seed_label: Label
@export var infiltrator_back_btn: Button
@export var infiltrator_copy_btn: Button

@export_category("Hacker")
@export var hacker_container: Control
@export var hacker_data_input: LineEdit
@export var hacker_start_btn: Button
@export var hacker_back_btn: Button

func _ready() -> void:
	show_controls()
	hacker_btn.pressed.connect(func(): show_controls(true))
	infiltrator_btn.pressed.connect(func(): show_controls(false, true))

	hacker_start_btn.pressed.connect(func(): _start_hacker())
	infiltrator_start_btn.pressed.connect(func(): _start_infiltrator())
	hacker_back_btn.pressed.connect(func(): show_controls())
	infiltrator_back_btn.pressed.connect(func(): show_controls())
	infiltrator_copy_btn.pressed.connect(func(): DisplayServer.clipboard_set("%s" % GameManager.seed))
	infiltrator_container.visibility_changed.connect(func(): infiltrator_seed_label.text = "%s" % GameManager.generate_new())

func _start_hacker():
	if hacker_data_input.text.is_empty():
		return

	GameManager.seed = int(hacker_data_input.text)
	GameManager.is_hacker = true
	get_tree().change_scene_to_packed(HEIST)

func _start_infiltrator():
	GameManager.is_hacker = false
	get_tree().change_scene_to_packed(HEIST)

func show_controls(hacker := false, infiltrator := false):
	mode_container.visible = not hacker and not infiltrator
	infiltrator_container.visible = infiltrator
	hacker_container.visible = hacker
