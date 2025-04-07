class_name PlayerReady
extends Node

signal all_players_ready()

@export var toggleable := false

var logger = NetworkLogger.new("PlayerReady")
var ready_players := []

func request_all_players_state():
	_request_ready_state.rpc()
	logger.info("Requesting player ready state")

@rpc("call_local", "reliable")
func _request_ready_state():
	_set_player_ready.rpc_id(1)

func notify_player_ready():
	_set_player_ready.rpc_id(1)
	logger.info("Sending player ready state")

@rpc("any_peer", "call_local", "reliable")
func _set_player_ready():
	var id = multiplayer.get_remote_sender_id()
	if not id in ready_players:
		ready_players.append(id)
		logger.info("Player %s is ready: %s / %s" % [id, ready_players.size(), Networking.players.size()])
		_check_players_ready()
	elif toggleable:
		ready_players.erase(id)
		logger.info("Player %s is not ready anymore: %s / %s" % [id, ready_players.size(), Networking.players.size()])

func _check_players_ready():
	var expected_players = Networking.players.size()
	if ready_players.size() >= expected_players:
		logger.info("All players ready")
		all_players_ready.emit()
