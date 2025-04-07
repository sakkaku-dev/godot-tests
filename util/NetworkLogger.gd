class_name NetworkLogger
extends Logger

func _format_message(msg: String):
	return "[%s] %s" % [Networking.get_player_id(), msg]
