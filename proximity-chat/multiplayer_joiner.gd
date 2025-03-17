class_name MultiplayerJoiner
extends MultiplayerSpawner

signal game_started()
signal players_updated(joined_players: Array)

@export var spawn_radius := 3.0
@export var player: PackedScene
@onready var root = get_node(spawn_path)

var joined_players := []
var spawned_players := {}

func _ready() -> void:
	Networking.player_connected.connect(func(id):
		joined_players.append(id)
		players_updated.emit(joined_players)
	)
	Networking.player_disconnected.connect(func(id):
		joined_players.erase(id)
		players_updated.emit(joined_players)

		if id in spawned_players:
			remove_player(id)
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if Networking.has_network():
			if multiplayer.is_server() and event.keycode == KEY_F1:
				start_game()
		else:
			if event.keycode == KEY_F1:
				Networking.host_game()
			elif event.keycode == KEY_F2:
				Networking.join_game("localhost")

func start_game():
	for i in joined_players.size():
		var angle = (TAU / joined_players.size()) * i
		add_player(joined_players[i], angle)
	
	_game_started.rpc()

func remove_player(id: int):
	if not id in spawned_players: return
	
	spawned_players[id].queue_free()
	spawned_players.erase(id)

func add_player(id: int, angle: float):
	var node = player.instantiate()
	node.name = str(id)
	node.position = (Vector3.FORWARD * spawn_radius).rotated(Vector3.UP, angle)
	root.add_child(node)
	spawned_players[id] = node

@rpc("call_local")
func _game_started():
	game_started.emit()
