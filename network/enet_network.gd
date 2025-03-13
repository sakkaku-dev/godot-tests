class_name ENetNetwork
extends Network

var port = 0
var max_peers = 0

func _init(p: int, max_p: int) -> void:
	port = p
	max_peers = max_p

func host_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_peers)
	peer_created.emit(peer)

func join_game(ip):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer_created.emit(peer)
