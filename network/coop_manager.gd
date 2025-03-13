extends Node

signal player_joined(id)
signal player_left(id)

@export var max_players := 4

var logger = Logger.new("CoopManager")
var joined_players := {}

func _ready() -> void:
	Networking.player_connected.connect(func(id):
		if not multiplayer.is_server(): return
		
		logger.info("Sending players to new player %s" % id)
		for player in joined_players.keys():
			send_player_joined.rpc_id(id, player)
	)

func remove_player(id: String):
	if not id.begins_with("%s_" % multiplayer.get_unique_id()):
		logger.info("Player %s is not owned by you" % id)
		return
	
	_remove_player.rpc(id)

@rpc("call_local", "any_peer")
func _remove_player(id: String):
	joined_players.erase(id)
	player_left.emit(id)

func add_player_by_input(ev: InputEvent):
	var id = "%s_%s" % [multiplayer.get_unique_id(), PlayerInput.create_id(ev)]
	if id in joined_players: return
	
	_add_new_player.rpc_id(1, id)

@rpc("call_local", "any_peer")
func _add_new_player(id: String):
	if joined_players.size() >= max_players:
		logger.warn("Max players reached")
		return
	
	if id in joined_players:
		logger.warn("Player %s has already joined" % id)
		return
	
	joined_players[id] = true
	send_player_joined.rpc(id)

@rpc("call_local")
func send_player_joined(id):
	logger.info("Player joined %s" % id)
	player_joined.emit(id)

func _create_input(event: InputEvent):
	var input = PlayerInput.new()
	input.set_for_event(event)
	return input

func _find_input_for(event: InputEvent):
	var joypad = PlayerInput.is_joypad_event(event)
	var device = event.device
	
	for c in get_children():
		if not c is PlayerInput: continue
		
		var input = c as PlayerInput
		if input.device_id == device and input.joypad == joypad:
			return input
	
	return null

func get_input_for_id(id: String):
	for c in get_children():
		if not c is PlayerInput: continue
		
		var input = c as PlayerInput
		if input.get_id() == id:
			return input
	return null
