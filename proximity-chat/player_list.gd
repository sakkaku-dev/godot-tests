class_name PlayerList
extends Control

@export var joiner: MultiplayerJoiner
@export var container: Control

func _ready() -> void:
	joiner.players_updated.connect(update_list)
	joiner.game_started.connect(func(): container.hide())

func update_list(players: Array):
	for c in container.get_children():
		c.queue_free()

	for id in players:
		var label = Label.new()
		label.text = Networking.get_player_name(id)
		container.add_child(label)
		print(id)
