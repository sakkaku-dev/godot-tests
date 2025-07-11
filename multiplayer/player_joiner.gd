class_name PlayerJoiner
extends Node

signal received_input(player_num: int, input: String)

signal all_players_ready()
signal players_ready_changed()

@export var colors: Array[Color] = []
@export var player_scene: PackedScene
@export var player_spawn: Node3D

var joined_players := {}
var players_ready := []
var disabled := false

var logger := Logger.new("PlayerJoiner")

func _ready():
	received_input.connect(_spawn_player)
	init_players()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("join"):
		player_join(event)

func remove_player(id):
	players_ready.erase(id)
	players_ready_changed.emit()

func reset_ready_state():
	players_ready = []
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
	
	if players_ready.size() == joined_players.size():
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
	
	var unique_id = "%s_%s" % [id, input]
	if unique_id in joined_players: return
	
	logger.info("Received join request for %s from %s" % [input, id])
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

func _spawn_player(player_num: int, input: String):
	var player = player_scene.instantiate()
	player.name = input
	player.color = colors[player_num % colors.size()]
	player.player_ready.connect(func(): player_toggle_ready(input))
	player_spawn.add_child(player)

func player_join(event: InputEvent):
	_join_player.rpc_id(1, PlayerInput.create_id(event))

func player_toggle_ready(id: String):
	toggle_ready.rpc_id(1, id)
