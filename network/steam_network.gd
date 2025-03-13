class_name SteamNetwork
extends Network

var steam_id := -1
var lobby_id := -1
var lobby_type := 0
var lobby_name : String

var max_peers: int
var port: int
var steam
var logger = Logger.new("SteamNetwork")

var multiplayer_class = "SteamMultiplayerPeer"

func _init(s, p: int, max_p: int) -> void:
	steam = s
	port = p
	max_peers = max_p

func _ready():
	steam.join_requested.connect(_on_lobby_join_requested)
	steam.lobby_created.connect(_on_lobby_created)
	steam.lobby_joined.connect(_on_lobby_joined)

func host_game():
	steam.createLobby(lobby_type, max_peers)

func _create_server():
	var peer = _create_multiplayer_class()
	if peer:
		peer.create_host(port, [])
		peer_created.emit(peer)

func _create_multiplayer_class():
	if not ClassDB.class_exists(multiplayer_class):
		logger.warn("Multiplayer class %s does not exist" % multiplayer_class)
		return
	
	return ClassDB.instantiate(multiplayer_class)

func join_game(id):
	lobby_id = id
	steam.joinLobby(lobby_id)

func _create_client():
	var peer = _create_multiplayer_class()
	if peer:
		peer.create_client(steam_id, port, [])
		peer_created.emit(peer)

func close_game():
	super.close_game()
	steam.leaveLobby(lobby_id)
	lobby_id = 0
	lobby_type = 0

func get_player_id(id):
	return multiplayer.multiplayer_peer.get_steam64_from_peer_id(id)

func _on_lobby_join_requested(_lobby_id: int, friend_id: int):
	var OWNER_NAME = steam.getFriendPersonaName(friend_id)
	logger.info("[STEAM] Joining "+str(OWNER_NAME)+"'s lobby...")
	join_game(_lobby_id)
	
func _on_lobby_created(_connect: int, _lobby_id: int):
	if _connect == 1:
		lobby_id = _lobby_id
		steam.setLobbyData(_lobby_id, "name", lobby_name)
		steam.setLobbyData(_lobby_id, "mode", str(lobby_type))
		logger.info("Lobby Created: %s" % _lobby_id)
		_create_server()
	else:
		connection_failed.emit()
		logger.info("Error creating lobby")

func _on_lobby_joined(_lobby_id: int, _permissions: int, _locked: bool, response: int):
	if response == 1:
		var id = steam.getLobbyOwner(_lobby_id)
		if id != steam.getSteamID():
			lobby_id = _lobby_id
			lobby_name = steam.getLobbyData(lobby_id, "name")
			logger.info("Joined Lobby")

			steam_id = id
			_create_client()
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			2:  FAIL_REASON = "This lobby no longer exists."
			3:  FAIL_REASON = "You don't have permission to join this lobby."
			4:  FAIL_REASON = "The lobby is now full."
			5:  FAIL_REASON = "Uh... something unexpected happened!"
			6:  FAIL_REASON = "You are banned from this lobby."
			7:  FAIL_REASON = "You cannot join due to having a limited account."
			8:  FAIL_REASON = "This lobby is locked or disabled."
			9:  FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		logger.info(FAIL_REASON)
		
