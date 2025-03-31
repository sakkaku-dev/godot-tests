extends Interactable

@export var scene: String
@onready var player_ready: PlayerReady = $PlayerReady

func _ready() -> void:
	player_ready.all_players_ready.connect(func(): teleport.rpc())
	interacted.connect(func(): player_ready.notify_player_ready())

@rpc("call_local", "reliable")
func teleport():
	get_tree().change_scene_to_file(scene)
