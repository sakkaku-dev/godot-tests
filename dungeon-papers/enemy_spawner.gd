class_name EnemySpawner
extends Marker3D

signal finished()

@export var enemy_scene: PackedScene
@export var spawn_timer: Timer

var processed_monsters: Array[DungeonGame.Builds] = []
var expected_builds: Dictionary[DungeonGame.Builds, int] = {}
var enemy_spawned := 0
var enemy_left := 0

func _ready() -> void:
	spawn_timer.timeout.connect(spawn)

func start(builds: Dictionary[DungeonGame.Builds, int], processed: Array[DungeonGame.Builds]) -> void: 
	expected_builds = builds
	processed_monsters = processed
	enemy_spawned = 0
	spawn_timer.start()

func stop():
	spawn_timer.stop()
	check_finished()

func get_current_enemy_count() -> int:
	return enemy_spawned

func spawn():
	var enemy = enemy_scene.instantiate()
	enemy.name = "Enemy %s" % enemy_spawned

	var build = get_next_monster_build()
	enemy.type = get_monster_for_build(build)
	enemy.left.connect(func():
		enemy_left += 1
		check_finished()
	)
	add_child(enemy)
	enemy_spawned += 1

func check_finished():
	if spawn_timer.is_stopped() and enemy_spawned == enemy_left:
		finished.emit()

func get_monster_for_build(build: DungeonGame.Builds) -> DungeonGame.Monster:
	var parts = DungeonGame.Builds.keys()[build].split("_")
	return DungeonGame.Monster[parts[0]] as DungeonGame.Monster

func get_next_monster_build():
	if expected_builds.is_empty():
		print("No more expected builds to spawn.")
		return null

	var keys = expected_builds.keys()
	var chances = []
	for k in keys:
		chances.append(max(expected_builds[k] - processed_monsters.count(k), 0))

	var total_chances = chances.reduce(func(a, b): return a + b, 0)
	if total_chances > 0:
		var random_value = randi() % total_chances

		var cumulative_chance = 0
		for i in range(keys.size()):
			cumulative_chance += chances[i]
			if random_value < cumulative_chance:
				return keys[i]
	
	return keys.pick_random()
