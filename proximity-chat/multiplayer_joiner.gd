class_name MultiplayerJoiner
extends MultiplayerSpawner

@export var player: PackedScene
@onready var root = get_node(spawn_path)

var spawned_players := {}

func _ready() -> void:
	Networking.player_connected.connect(func(id): add_player(id))
	Networking.player_disconnected.connect(func(id): remove_player(id))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_F1:
			Networking.host_game()
		elif event.keycode == KEY_F2:
			Networking.join_game("localhost")

func remove_player(id: int):
	if not id in spawned_players: return
	
	spawned_players[id].queue_free()
	spawned_players.erase(id)

func add_player(id: int):
	print("Add player %s" % id)
	var node = player.instantiate()
	node.name = str(id)
	root.add_child(node)
	spawned_players[id] = node
