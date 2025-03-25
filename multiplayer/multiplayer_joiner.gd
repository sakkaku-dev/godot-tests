class_name MultiplayerJoiner
extends MultiplayerSpawner

signal all_players_ready()
signal game_started()

@export var spawn_radius := 3.0
@export var player: PackedScene
@onready var root = get_node(spawn_path)

var ready_players := []

func _ready() -> void:
	if not Networking.has_network():
		add_player(0, 0)
		return
	
	await get_tree().create_timer(1.0).timeout
	_set_player_ready.rpc_id(1)
	print("Sending server ready state")

@rpc("any_peer", "call_local", "reliable")
func _set_player_ready():
	var id = multiplayer.get_remote_sender_id()
	if not id in ready_players:
		ready_players.append(id)
		print("Player %s is ready: %s / %s" % [id, ready_players.size(), Networking.players.size()])
		_check_players_ready()

func _check_players_ready():
	var expected_players = Networking.players.size()
	if ready_players.size() >= expected_players:
		all_players_ready.emit()
		print("All players ready")
		start_game()

func start_game():
	var players = Networking.players.keys()
	if players.is_empty():
		players.append(0)
	
	for i in players.size():
		var angle = (TAU / players.size()) * i
		add_player(players[i], angle)
	
	_game_started.rpc()

func add_player(id: int, angle: float):
	var node = player.instantiate()
	node.name = str(id)
	node.position = (Vector3.FORWARD * spawn_radius).rotated(Vector3.UP, angle)
	root.add_child(node)

@rpc("call_local")
func _game_started():
	game_started.emit()
	print("Starting game")
