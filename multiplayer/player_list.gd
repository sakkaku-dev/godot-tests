class_name PlayerList
extends Control

@export var container: Control
@export var game_scene: PackedScene

func _ready() -> void:
	Networking.player_list_changed.connect(func(): update_list(Networking.players.keys()))

func update_list(players: Array):
	for c in container.get_children():
		c.queue_free()

	for id in players:
		var label = Label.new()
		label.text = Networking.get_player_name(id)
		container.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if Networking.has_network():
			if multiplayer.is_server() and event.keycode == KEY_F1:
				_change_scene.rpc()
		else:
			if event.keycode == KEY_F1:
				Networking.host_game()
			elif event.keycode == KEY_F2:
				Networking.join_game("localhost")

@rpc("call_local", "reliable")
func _change_scene():
	get_tree().change_scene_to_packed(game_scene)
