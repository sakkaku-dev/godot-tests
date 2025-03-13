class_name Network
extends Node

signal peer_created(peer)
signal connection_failed()

func host_game():
	pass

func join_game(id):
	pass

func close_game():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null

func get_player_id(id):
	return id

func get_player_name(id):
	return "Player %s" % id
