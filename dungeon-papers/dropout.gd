class_name Dropout
extends Area3D

signal build_failed(monster)
signal build_successful(build: DungeonGame.Builds)

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D) -> void:
	var monster = body as DungeonMonster
	if not monster: return

	var type = monster.type
	var build = get_build_for_monster(monster)
	monster.remove()

	if not build:
		print("No matching build found for monster: ", type)
		build_failed.emit(type)
		return

	build_successful.emit(build)

func get_build_for_monster(monster: DungeonMonster):
	var items = monster.get_items()
	var type = monster.get_type_string()
	var possible_builds = DungeonGame.BUILD_ITEMS_MAP.keys().filter(func(x): return x.begins_with(type) and DungeonGame.BUILD_ITEMS_MAP[x].size() == items.size())
	if not possible_builds: return
	
	var unique_items = []
	for i in items:
		if not i in unique_items:
			unique_items.append(i)

	for p in possible_builds:
		var expected_items = DungeonGame.BUILD_ITEMS_MAP[p]
		if is_build_same(items, expected_items):
			return p
	
	return null

func is_build_same(items: Array, expected_items: Array) -> bool:
	if items.size() != expected_items.size():
		return false

	for i in items:
		if expected_items.count(i) != items.count(i):
			return false

	return true
