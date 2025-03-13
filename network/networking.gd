extends Node

const MAX_PEERS = 4
const DEFAULT_PORT = 14420

signal player_list_changed()
signal player_connected(id)
signal player_disconnected(id)
signal connection_failed()
signal connection_success()
signal game_error(err)

var network: Network
var logger = Logger.new("Networking")

var players := {}
var connected := false

func _ready():
	network = SteamNetwork.new(SteamManager.steam, DEFAULT_PORT, MAX_PEERS) if Env.is_steam() else ENetNetwork.new(DEFAULT_PORT, MAX_PEERS)
	add_child(network)

	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)

	# Only called by clients
	multiplayer.connected_to_server.connect(func():
		logger.info("Connection success")
		_player_connected(multiplayer.get_unique_id())
		connection_success.emit()
	)
	multiplayer.connection_failed.connect(func():
		logger.info("Connection failed")
		connection_failed.emit()
	)
	multiplayer.server_disconnected.connect(func():
		reset_network()
		get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
		logger.info("Server disconnected")
		game_error.emit("Server disconnected")
	)
	connection_success.connect(func(): connected = true)

	network.peer_created.connect(func(peer):
		multiplayer.multiplayer_peer = peer
		_player_connected(1)
		connection_success.emit()
	)
	network.connection_failed.connect(func(): connection_failed.emit())

func host_game():
	network.host_game()
	logger.info("Hosting server")

func join_game(id):
	network.join_game(id)
	logger.info("Joining server %s" % id)

func has_network():
	return connected

func _player_connected(id):
	players[id] = network.get_player_id(id)
	player_list_changed.emit()
	player_connected.emit(id)
	logger.info("Client Connected: %s" % id)

func _player_disconnected(id):
	players.erase(id)
	player_list_changed.emit()
	player_disconnected.emit(id)
	logger.info("Client Disconnected: %s" % id)

func get_player_count():
	return players.size()

func get_player_id(id = multiplayer.get_unique_id()):
	if not id in players: return null
	return players[id]

func get_player_name(id):
	var player_id = get_player_id(id)
	return network.get_player_name(player_id)

func reset_network():
	logger.info("Connection reset")
	network.close_game()
	players = {}
