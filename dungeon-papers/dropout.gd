class_name Dropout
extends Area3D

signal build_failed(monster)
signal build_successful(build: Builds)

enum Builds {
	SKELETON_MAGE,
	SKELETON_WARRIOR,
	SKELETON_ARCHER,

	GOBLIN_SHAMAN,
	GOBLIN_WARRIOR,
}

const BUILD_ITEMS_MAP = {
	DungeonMonster.Type.SKELETON: {
	#Builds.SKELETON_MAGE: [Item.Type.POTION, Item.Type.ROBE, Item.Type.STAFF],
	Builds.SKELETON_WARRIOR: ["Sword"],
	#Builds.SKELETON_ARCHER: [Item.Type.CROSSBOW, Item.Type.QUIVER, Item.Type.ARROW, Item.Type.ARROW, Item.Type.ARROW, Item.Type.ARROW, Item.Type.ARROW],
	}
	#Builds.GOBLIN_SHAMAN: [Item.Type.POTION],
	#Builds.GOBLIN_WARRIOR: [Item.Type.SWORD, Item.Type.SHIELD],
}

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D) -> void:
	var monster = body as DungeonMonster
	if not monster: return

	var type = monster.type
	var build = get_build_for_monster(monster)
	monster.queue_free()

	if not build:
		print("No matching build found for monster: ", type)
		build_failed.emit(type)
		return

	print("Build found for monster: ", DungeonMonster.Type.keys()[type], " - ", Builds.keys()[build])
	build_successful.emit(build)

func get_build_for_monster(monster: DungeonMonster):
	var items = monster.get_items()
	var builds = BUILD_ITEMS_MAP.get(monster.type)
	if not builds: return
	
	var possible_builds = builds.keys().filter(func(x): return builds[x].size() == items.size())
	var unique_items = []
	for i in items:
		if not i in unique_items:
			unique_items.append(i)

	for p in possible_builds:
		var expected_items = BUILD_ITEMS_MAP[p]
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
