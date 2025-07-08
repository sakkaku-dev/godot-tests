class_name PlayerJoiner
extends Node

signal received_input(player_num: int, input: String)

signal players_reset()
signal all_players_ready()
signal players_ready_changed()

var joined_players := {}
var players_ready := []
var disabled := false

var logger := Logger.new("PlayerJoiner")

func reset():
	reset_ready_state()

func remove_player(id):
	players_ready.erase(id)
	players_ready_changed.emit()

func reset_ready_state():
	players_ready = []
	players_reset.emit()
	players_ready_changed.emit()
	logger.info("Reset player ready state")

func get_ready_players():
	return players_ready.size()

@rpc("call_local", "reliable", "any_peer")
func toggle_ready(id):
	if id in players_ready:
		players_ready.erase(id)
	else:
		players_ready.append(id)
	
	players_ready_changed.emit()
	
	if players_ready.size() == Networking.get_player_count():
		all_players_ready.emit()
		logger.info("All players ready")

@rpc("call_local", "reliable", "any_peer")
func _request_spawned_players():
	var requester = multiplayer.get_remote_sender_id()
	for id in joined_players.keys():
		player_spawned.rpc_id(requester, id)
	logger.info("Player %s requests all player data: %s" % [requester, joined_players.keys()])

@rpc("call_local", "reliable", "any_peer")
func _join_player(input: String):
	if disabled:
		logger.warn("Player joining is disabled")
		return

	var id = multiplayer.get_remote_sender_id()
	logger.info("Received join request for %s from %s" % [input, id])
	
	var unique_id = "%s_%s" % [id, input]
	if unique_id in joined_players:
		logger.warn("Player %s already exists" % unique_id)
		return
	
	joined_players[unique_id] = true
	player_spawned.rpc(joined_players.size(), unique_id)

### Client Side ###
var spawned_players := []

func init_players():
	if multiplayer.is_server():
		return
	
	_request_spawned_players.rpc_id(1)

@rpc("call_local", "reliable")
func player_spawned(player_num: int, input: String):
	logger.debug("Spawning %s" % input)
	if input not in spawned_players:
		received_input.emit(player_num, input)
		spawned_players.append(input)

func player_join(event: InputEvent):
	_join_player.rpc_id(1, PlayerInput.create_id(event))

func player_toggle_ready(id: String):
	toggle_ready.rpc_id(1, id)
