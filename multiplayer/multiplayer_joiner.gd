class_name MultiplayerJoiner
extends MultiplayerSpawner

signal finished()
signal all_died()

@export var use_oxygen := false
@export var spawn_radius := 3.0
@export var player: PackedScene
@onready var root = get_node(spawn_path)
@onready var player_ready: PlayerReady = $PlayerReady

var logger = NetworkLogger.new("MultiplayerJoiner")

var current_players := []
var player_died := 0:
	set(v):
		player_died = v
		if player_died >= current_players.size():
			all_died.emit()

func _ready() -> void:
	if not Networking.has_network():
		add_player(0, 0)
		return
	
	player_ready.all_players_ready.connect(func(): start_game())
	await get_tree().create_timer(1.0).timeout
	
	if multiplayer.is_server():
		player_ready.request_all_players_state()
	else:
		player_ready.notify_player_ready()

func start_game():
	var players = get_player_ids()
	for i in players.size():
		var angle = (TAU / players.size()) * i
		add_player(players[i], angle)
	
	current_players = players
	_game_started.rpc()

func get_player_ids():
	var players = Networking.players.keys()
	if players.is_empty():
		players.append(0)
	return players

func add_player(id: int, angle: float):
	var node = player.instantiate()
	node.name = str(id)
	node.position = (Vector3.FORWARD * spawn_radius).rotated(Vector3.UP, angle)
	node.died.connect(func(): player_died += 1)
	root.add_child(node)

	if use_oxygen:
		node.start_oxygen()

func get_player_node(id: int = Networking.get_player_id()):
	return root.get_node("%s" % id)

@rpc("call_local")
func _game_started():
	finished.emit()
