class_name MultiplayerStart
extends Control

@export var container: Control
@export var game_scene: PackedScene

func _ready() -> void:
	Networking.connection_success.connect(func():
		await get_tree().create_timer(1.0).timeout
		_change_scene()
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_F1:
			Networking.host_game()
		elif event.keycode == KEY_F2:
			Networking.join_game("localhost")

func _change_scene():
	get_tree().change_scene_to_packed(game_scene)
