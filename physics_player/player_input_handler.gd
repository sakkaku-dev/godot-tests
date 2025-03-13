class_name PlayerInputHandler
extends Node

signal received_input(remote: int, id: String)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_received_input(PlayerInput.create_id(event))
		#if not Networking.has_network():
			#Networking.host_game()
			#_received_input.rpc_id(1, PlayerInput.create_id(event))
		#else:
			#_received_input.rpc_id(1, PlayerInput.create_id(event))

@rpc("call_local", "any_peer")
func _received_input(input_id: String):
	print("Received input %s from %s" % [input_id, multiplayer.get_remote_sender_id()])
	received_input.emit(multiplayer.get_remote_sender_id(), input_id)
