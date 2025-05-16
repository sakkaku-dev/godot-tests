class_name PlayerItems
extends Control

signal event(text: String)
signal died()

@export var money_label: Label
@export var hunger_label: Label
@export var thirst_label: Label
@export var health_container: Control
@export var items_container: Control

@export var injury_chance:= 0.2
@export var animal_attack_chance := 0.2
@export var cold_chance := 0.2
@export var thunder_chance := 0.05

var health := 3:
	set(v):
		health = clamp(v, 0, 3)
		for i in range(health_container.get_child_count()):
			var child = health_container.get_child(i) as TextureRect
			if child:
				child.modulate = Color.WHITE if i < health else Color.TRANSPARENT
		
var hunger := 10:
	set(v):
		hunger = min(v, 10)
		hunger_label.text = "%s" % hunger
var thirst := 10:
	set(v):
		thirst = min(v, 10)
		thirst_label.text = "%s" % thirst
var money := 100:
	set(v):
		money = v
		money_label.text = "%s" % money

var items := []

func _ready() -> void:
	self.hunger = hunger
	self.thirst = thirst
	self.money = money
	self.health = health

func add_items(new_items: Array):
	items.append_array(new_items)
	update_items()

func update_items():
	var unique_items = []
	for item in items:
		if not unique_items.has(item):
			unique_items.append(item)
	
	var item_counts = {}
	for item in unique_items:
		item_counts[item] = items.count(item)

	var children = items_container.get_children()
	for i in range(children.size()):
		var slot = children[i] as ItemSlot
		if slot:
			if i >= unique_items.size():
				slot.resource = null
				continue

			var res = unique_items[i]
			slot.resource = res
			slot.count = item_counts[res]

func finished_trip():
	items = items.filter(func(i): return i.type == ItemResource.Type.SWEETS)
	update_items()

func take_step(weather: Expedition.Weather, terrain: ExpeditionMap.Terrain):
	hunger -= _get_hunger_multiplier(terrain, weather)
	thirst -= _get_thirst(terrain, weather)

	var injury_decrease = count_item(ItemResource.Type.GLOVES) / 6.0
	var injury = injury_chance * (1 - injury_decrease)

	var attack_block_chance = count_item(ItemResource.Type.ARMOR) / 2.0
	var animal_attack = animal_attack_chance * (1 - attack_block_chance)

	var cold_decrease = count_item(ItemResource.Type.CLOTHES) / 2.0
	var cold = cold_chance * (1 - cold_decrease)

	if terrain == ExpeditionMap.Terrain.JUNGLE:
		if randf() < animal_attack:
			health -= 1
			event.emit("You were attacked by a wild animal")
		if randf() < injury:
			health -= 1
			event.emit("You were injuried by thorns")
	elif terrain == ExpeditionMap.Terrain.MOUNTAIN:
		var multi = 0.5 if weather in WET_WEATHER else 1.0
		if randf() * multi < cold:
			health -= 1
			event.emit("You are freezing and got frostbite")
		if randf() < injury:
			health -= 1
			event.emit("You were injuried by rocks")
	elif terrain == ExpeditionMap.Terrain.RIVER or terrain == ExpeditionMap.Terrain.PLAINS:
		if weather in WET_WEATHER:
			if randf() < cold:
				health -= 1
				event.emit("You caught a cold")
		if weather == Expedition.Weather.THUNDER and randf() < thunder_chance:
			health -= 1
			event.emit("You were struck by lightning")

	var weight = count_item(ItemResource.Type.ARMOR) * 0.5
	var speed = min(count_item(ItemResource.Type.BOOTS) / 4.0, 0.75)
	return _get_time_for_walk(terrain, weather) * (1 - speed) + weight

func count_item(type: ItemResource.Type) -> int:
	var count = 0
	for item in items:
		if item.type == type:
			count += 1
	return count

func take_item(type: ItemResource.Type) -> bool:
	var idx = -1
	for i in range(items.size()):
		var item = items[i]
		if item.type == type:
			idx = i
			break
	
	if idx != -1:
		items.remove_at(idx)
		update_items()
		return true

	return false

func process_items():
	if hunger <= 5:
		if take_item(ItemResource.Type.FOOD):
			hunger += 5
			event.emit("You ate a food supply")
			return true
		elif take_item(ItemResource.Type.SWEETS):
			hunger += 2
			event.emit("You ate sweets")
			return true
	elif thirst <= 5 and take_item(ItemResource.Type.WATER):
		thirst += 5
		event.emit("You drank a water bottle")
		return true
	elif health < 3 and take_item(ItemResource.Type.HERBS):
		health += 1
		event.emit("You used herbs to treat your wounds")
		return true
	
	return false

func check_death():
	if not has_died(): return

	if hunger <= 0:
		event.emit("You starved to death")
	elif thirst <= 0:
		event.emit("You died of thirst")
	elif health <= 0:
		event.emit("You died from health issues")
	died.emit()

func use_up_food():
	if take_item(ItemResource.Type.FOOD):
		hunger += 5
	if take_item(ItemResource.Type.WATER):
		thirst += 5

func has_died():
	return health <= 0 or hunger <= 0 or thirst <= 0

const EXHAUSTING_TERRAIN = [ExpeditionMap.Terrain.JUNGLE, ExpeditionMap.Terrain.MOUNTAIN]
const WET_WEATHER = [Expedition.Weather.RAIN, Expedition.Weather.THUNDER]

func _get_hunger_multiplier(terrain: ExpeditionMap.Terrain, weather: Expedition.Weather) -> int:
	var reduction = 1
	if terrain in EXHAUSTING_TERRAIN:
		reduction += 1
	# if weather == Expedition.Weather.SCORCHING:
	# 	reduction += 1

	return reduction

func _get_time_for_walk(terrain: ExpeditionMap.Terrain, weather: Expedition.Weather) -> float:
	var glove_improve = 1.0 if count_item(ItemResource.Type.GLOVES) else 0.0

	match terrain:
		ExpeditionMap.Terrain.MOUNTAIN:
			return 3 - glove_improve
		ExpeditionMap.Terrain.JUNGLE:
			return 2 - glove_improve
		ExpeditionMap.Terrain.RIVER:
			if weather in WET_WEATHER:
				return 2
	return 1

func _get_thirst(terrain: ExpeditionMap.Terrain, weather: Expedition.Weather) -> int:
	var reduction = 2
	if terrain == ExpeditionMap.Terrain.RIVER:
		reduction -= 1
	if terrain in EXHAUSTING_TERRAIN:
		reduction += 1

	if weather in WET_WEATHER:
		reduction -= 1
	if weather == Expedition.Weather.SCORCHING:
		reduction += 1
		if count_item(ItemResource.Type.CLOTHES) > 0:
			reduction += 1
	
	return reduction
