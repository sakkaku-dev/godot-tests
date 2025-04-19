extends Node

var game_seed := 0

@export var loading_screen: Control
@export var terrain: Terrain
@export var gameover_scene: String

@onready var multiplayer_joiner: MultiplayerJoiner = $MultiplayerJoiner
@onready var player_ready: PlayerReady = $PlayerReady
@onready var gameover_timer: Timer = $GameoverTimer

var logger = NetworkLogger.new("MarsGame")

func _ready() -> void:
	get_tree().paused = true
	
	if multiplayer.is_server():
		multiplayer_joiner.finished.connect(_init_seed)
		multiplayer_joiner.all_died.connect(func(): gameover_timer.start())
		player_ready.all_players_ready.connect(func(): _start_game.rpc())
		gameover_timer.timeout.connect(func(): _game_over.rpc())

@rpc("call_local", "reliable")
func _game_over():
	Networking.reset_network()
	get_tree().change_scene_to_file(gameover_scene)

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
