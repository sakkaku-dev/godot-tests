class_name EnemySpawner
extends Marker3D

@export var max_enemy_count := 8
@export var enemy_scene: PackedScene
@export var spawn_timer: Timer

var types: Array[DungeonMonster.Type] = []
var enemy_spawned := 0

func _ready() -> void:
	spawn_timer.timeout.connect(spawn)

func start(types: Array[DungeonMonster.Type] = []):
	self.types = types
	enemy_spawned = 0
	spawn_timer.start()

func stop():
	spawn_timer.stop()
	for e in get_tree().get_nodes_in_group(DungeonMonster.GROUP):
		e.queue_free()

func get_current_enemy_count() -> int:
	return enemy_spawned

func spawn():
	if get_current_enemy_count() >= max_enemy_count:
		print("Max enemy count reached, cannot spawn more.")
		return

	var enemy = enemy_scene.instantiate()
	enemy.name = "Enemy %s" % enemy_spawned
	enemy.type = types.pick_random()
	#enemy.rotation.y = rotation.y

	add_child(enemy)
	enemy_spawned += 1
