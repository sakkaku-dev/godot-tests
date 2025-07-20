extends Node3D

@export var player_joiner: PlayerJoiner
@export var round_timer: Timer
@export var dropout: Dropout
@export var enemy_spawner: EnemySpawner
@export var chest: Chest

@export_category("UI")
@export var money_label: Label
@export var goal_container: Control

var build_labels: Dictionary[DungeonGame.Builds, Label] = {}

var health := 3
var money := 0:
	set(v):
		money = v
		money_label.text = "%s$" % money
var rounds := 0
var is_running := false:
	set(v):
		if v == is_running: return
		is_running = v
		
		if is_running:
			DungeonGame.start_round()
			setup_round(rounds)
		else:
			DungeonGame.end_round()
			_end_round()

var processed_monsters: Array[DungeonGame.Builds] = []
var failed_monsters: Array[DungeonGame.Monster] = []

var available_builds: Array[DungeonGame.Builds] = []
var expected_builds: Dictionary[DungeonGame.Builds, int] = {}

func _ready() -> void:
	self.money = money
	if not multiplayer.is_server(): return
	chest.add_items(["Furnace", "Anvil"])

	round_timer.timeout.connect(func(): enemy_spawner.stop())
	enemy_spawner.finished.connect(func(): _end_round())
	dropout.build_successful.connect(func(build):
		processed_monsters.append(build)
	)
	dropout.build_failed.connect(func(monster): failed_monsters.append(monster))
	player_joiner.all_players_ready.connect(func(): is_running = true)

func _update_builds(build: DungeonGame.Builds):
	build_labels[build].text = "%s - %s / %s" % [DungeonGame.Builds.keys()[build], processed_monsters.count(build), expected_builds[build]]

func _end_round():
	player_joiner.reset_ready_state()
	money += processed_monsters.size() * 10
	rounds += 1
	is_running = false

func setup_round(current_round: int):
	available_builds.clear()
	processed_monsters.clear()
	for c in goal_container.get_children():
		c.queue_free()

	if current_round == 0:
		available_builds = [DungeonGame.Builds.SKELETON_WARRIOR]
	elif current_round == 1:
		available_builds = [DungeonGame.Builds.SKELETON_WARRIOR, DungeonGame.Builds.GOBLIN_WARRIOR]
	elif current_round >= 2:
		available_builds = [DungeonGame.Builds.SKELETON_WARRIOR, DungeonGame.Builds.GOBLIN_WARRIOR, DungeonGame.Builds.SKELETON_ARCHER]

	expected_builds = {}
	for m in available_builds:
		expected_builds[m] = randi_range(1, 5)
		var label = Label.new()
		build_labels[m] = label
		goal_container.add_child(label)
		_update_builds(m)
	
	round_timer.start()
	enemy_spawner.start(expected_builds, processed_monsters)
