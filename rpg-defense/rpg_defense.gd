extends Node3D

@export var game_over_ui: Control
@export var money_label: Label
@export var map: GameMap
@export var player_scene: PackedScene
@export var root_spawn: Node3D

@export var player_joiner: PlayerJoiner
@export var colors: Array[Color] = []

@onready var main_base: MainBase = $MainBase
@onready var enemy_spawner: EnemySpawner = $EnemySpawner

var has_game_started := false:
	set(v):
		player_joiner.disabled = v
		has_game_started = v
		for p in get_tree().get_nodes_in_group(PhysicsPlayer.GROUP):
			p.is_character_select = not has_game_started

var money := 0:
	set(v):
		money = v
		money_label.text = "%s$" % money
		money_label.visible = has_game_started

func _ready() -> void:
	self.money = money
	game_over_ui.hide()

	player_joiner.received_input.connect(_spawn_player)
	player_joiner.init_players()

	if multiplayer.is_server():
		main_base.died.connect(func(): _game_over.rpc())
		enemy_spawner.enemy_killed.connect(func(): money += 10)
		player_joiner.all_players_ready.connect(func():
			has_game_started = true
			enemy_spawner.start_wave()
			player_joiner.reset_ready_state()
		)

@rpc("call_local", "reliable", "any_peer")
func place_block(res: BlockResource, coord: Vector3i) -> void:
	if not has_game_started:
		print("Cannot place blocks before the game starts.")
		return
	
	if money >= res.cost:
		money -= res.cost
		map.place_block(res, coord)
	else:
		print("Not enough money to place block: %s" % BlockResource.Type.keys()[res.type])

### Client Side ###
@rpc("call_local", "reliable")
func _game_over():
	game_over_ui.show()

func _spawn_player(player_num: int, input: String):
	var player = player_scene.instantiate()
	player.name = input
	player.color = colors[player_num % colors.size()]
	player.placed_block.connect(func(res: BlockResource, coord: Vector3i): place_block.rpc_id(1, res, coord))
	player.player_ready.connect(func():
		if enemy_spawner.is_active(): return
		player_joiner.player_toggle_ready(input)
	)
	root_spawn.add_child(player)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("join"):
		player_joiner.player_join(event)
		print("Pressed %s" % event)
