extends MultiplayerSpawner

@export var player_colors := [Color.RED, Color.CYAN, Color.GREEN, Color.YELLOW, Color.VIOLET]
@export var player_scene: PackedScene

@onready var root = get_node(spawn_path)
@onready var player_input_handler: PlayerInputHandler = $PlayerInputHandler

var players = {0: []}

func _ready() -> void:
	#Networking.connection_success.connect(func(): players[multiplayer.get_unique_id()] = [])
	#Networking.player_connected.connect(func(id): players[id] = [])
	#Networking.player_disconnected.connect(func(id): players.erase(id))
	
	#if multiplayer.is_server():
	player_input_handler.received_input.connect(func(remote, input_id): spawn_new_player(remote, input_id))

#func spawn_input_handler(id: int):
	#var node = PlayerInputHandler.new()
	#node.name = id
	#add_child(node)

func spawn_new_player(id: int, input_id: String):
	print("Spawning new player %s: %s" % [id, input_id])
	
	if not id in players:
		print("Player is not connected: %s" % id)
		return
	if input_id in players[id]:
		print("Player %s input already exist: %s" % [id, input_id])
		return
	
	players[id].append(input_id)
	
	var node = player_scene.instantiate()
	node.name = "%s" % id
	node.input_id = input_id
	node.color = player_colors.pick_random()
	player_colors.erase(node.color)
	
	root.add_child(node)
