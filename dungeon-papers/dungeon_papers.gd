extends Node3D

const BUILD_ATTACKS = {
	Dropout.Builds.SKELETON_MAGE: 1,
	Dropout.Builds.SKELETON_WARRIOR: 2,
	Dropout.Builds.SKELETON_ARCHER: 3,
	Dropout.Builds.GOBLIN_SHAMAN: 1,
	Dropout.Builds.GOBLIN_WARRIOR: 2,
}

@export var player_joiner: PlayerJoiner
@export var round_timer: Timer
@export var dropout: Dropout
@export var enemy_spawner: EnemySpawner
@export var money_label: Label

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

var available_monsters: Array[DungeonMonster.Type] = []
var processed_monsters: Array[Dropout.Builds] = []
var failed_monsters: Array[DungeonMonster.Type] = []
var hero_attack_value := 0

func _ready() -> void:
	if not multiplayer.is_server(): return

	round_timer.timeout.connect(func(): _end_round())
	dropout.build_successful.connect(func(build): processed_monsters.append(build))
	dropout.build_failed.connect(func(monster): failed_monsters.append(monster))
	player_joiner.all_players_ready.connect(func(): is_running = true)

func _end_round():
	player_joiner.reset_ready_state()
	enemy_spawner.stop()
	money += processed_monsters.size() * 10

	var monster_attack = get_monster_attack_value()
	if monster_attack > hero_attack_value:
		rounds += 1
	else:
		health -= 1
	
	is_running = false

func setup_round(round: int):
	available_monsters.clear()
	processed_monsters.clear()

	if round == 0:
		available_monsters = [DungeonMonster.Type.SKELETON]
		hero_attack_value = 5
	elif round == 1:
		available_monsters = [DungeonMonster.Type.SKELETON, DungeonMonster.Type.GOBLIN, DungeonMonster.Type.SLIME]
		hero_attack_value = 10
	elif round >= 2:
		available_monsters = [DungeonMonster.Type.DRAGON]
		hero_attack_value = 20
	
	round_timer.start()
	enemy_spawner.start(available_monsters)

func get_monster_attack_value() -> int:
	return processed_monsters.reduce(func(acc, build): return acc + BUILD_ATTACKS.get(build, 0), 0)
