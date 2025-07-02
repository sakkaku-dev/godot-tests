extends Label

func _ready() -> void:
	_update()
	Networking.player_list_changed.connect(_update)

func _update():
	text = "%s" % Networking.players.size()
