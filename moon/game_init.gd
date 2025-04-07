extends Node

var game_seed := 0

@export var loading_screen: Control
@export var terrain: Terrain

@onready var multiplayer_joiner: MultiplayerJoiner = $MultiplayerJoiner
@onready var player_ready: PlayerReady = $PlayerReady

var logger = NetworkLogger.new("MarsGame")

func _ready() -> void:
	get_tree().paused = true
	
	if multiplayer.is_server():
		multiplayer_joiner.finished.connect(_init_seed)
		player_ready.all_players_ready.connect(func(): _start_game.rpc())

func _init_seed():
	randomize()
	_setup_seed.rpc(randi())
	
@rpc("call_local", "reliable")
func _setup_seed(seed: int):
	seed(seed)
	game_seed = seed
	terrain.apply_seed(seed)
	logger.info("Setting game seed: %s" % seed)
	_generate_map()

func _generate_map():
	logger.info("Setting up map")
	terrain.player = multiplayer_joiner.get_player_node()
	terrain.finished.connect(func(): player_ready.notify_player_ready())
	
	if not terrain.player:
		logger.info("Player not found")

@rpc("call_local", "reliable")
func _start_game():
	logger.info("Starting game")
	get_tree().paused = false
	loading_screen.hide()
