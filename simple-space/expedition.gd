class_name Expedition
extends Node2D

enum Weather {
	SCORCHING,
	SUNNY,
	RAIN,
	THUNDER,
}

@export var items: PlayerItems
@export var shop: ExpeditionShop
@export var map: ExpeditionMap
@export var day_label: Label
@export var weather_label: Label
@export var intro_label: Label

@export_category("Buttons")
@export var button_container: Control
@export var start_button: TextureButton
@export var shop_button: TextureButton
@export var weather_button: TextureButton

@export_category("Weather")
@export var weather_sprite: AnimatedSprite2D
@export var weather_noise: FastNoiseLite
@export var sunny_threshold := 0.0
@export var rain_threshold := 0.2
@export var thunder_threshold := 0.4

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var paper_sfx: AudioStreamPlayer = $PaperSFX
@onready var pickup_money_sfx: AudioStreamPlayer = $PickupMoneySFX
@onready var process_timer: Timer = $ProcessTimer

const WEATHER_ANIM = {
	Weather.SCORCHING: "noon",
	Weather.SUNNY: "day",
	Weather.RAIN: "raining",
	Weather.THUNDER: "lightning",
}

const MAP_SIZE = [
	Vector2.ZERO,
	Vector2(4, 2),
	Vector2(5, 3),
	Vector2(6, 3),
	Vector2(7, 4),
	Vector2(8, 4),
]

enum Process {
	RUN,
	ITEMS,
}

var process := Process.RUN
var run := 0:
	set(v):
		run = v

		var map_size = MAP_SIZE[run] if run < MAP_SIZE.size() else MAP_SIZE[MAP_SIZE.size() - 1]
		map.depth = map_size.x
		map.max_height = map_size.y
		map.inflation = get_inflation()
		map.generate_map()

var day_time = 1.0:
	set(v):
		day_time = v
		day_label.text = "Day %s" % int(day_time)
		
		var w = get_weather()
		weather_label.text = "%s" % Weather.keys()[w]

		var anim = WEATHER_ANIM[w]
		if weather_sprite.animation != anim:
			weather_sprite.play(anim)

func get_inflation():
	return 1.0 # + max((day_time-1) / 100.0, 0)

func swap_paper(reverse = false):
	if reverse:
		animation_player.play_backwards("shop")
	else:
		animation_player.play("shop")
	paper_sfx.play()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not process_timer.is_stopped():
		process_timer.stop()
		do_process()

func _ready() -> void:
	randomize()
	self.day_time = day_time
	prepare_run()

	process_timer.timeout.connect(func(): do_process())
	items.event.connect(func(text: String): intro_label.text = text)
	map.picked_money.connect(func(m: int):
		items.money += m
		pickup_money_sfx.play()
	)
	map.marked.connect(func(): _update_map_controls())
	weather_noise.seed = randi()
	
	shop_button.pressed.connect(func():
		_sync_shop()
		swap_paper()
		shop.open_shop(get_inflation())
	)
	weather_button.pressed.connect(func():
		swap_paper()
		shop.open_weather(day_time, func(x): return get_weather(x))
	)
	start_button.pressed.connect(func():
		if map.has_reached_end():
			if items.has_died():
				get_tree().reload_current_scene()
			else:
				map.stop_game()
				prepare_run()
		else:
			start_run()
	)
	
	shop.back.connect(func(): swap_paper(true))
	shop.bought.connect(func(new_items: Array, total_price: int):
		items.money -= total_price
		items.add_items(new_items)
		shop.reset_slots()
		_sync_shop()
	)

func _update_map_controls():
	var started = map.is_game_running()

	if not started:
		intro_label.text = "Plan your trip by clicking\nthe first point on the left" if map.path.is_empty() else "Plan a path to one of\nthe right points"
	else:
		intro_label.text = ""

	intro_label.visible = not map.has_finished_marking() or started
	start_button.visible = map.has_finished_marking() and not started

func get_weather(time: float = day_time):
	if day_time <= 3:
		return Weather.SUNNY
	
	var v = weather_noise.get_noise_1d(time)
	if v >= thunder_threshold:
		return Weather.THUNDER
	if v >= rain_threshold:
		return Weather.RAIN
	if v >= sunny_threshold:
		return Weather.SUNNY
	return Weather.SCORCHING

func _sync_shop():
	shop.current_items = items.items
	shop.current_money = items.money
	shop.update_slots()

func prepare_run():
	run += 1
	start_button.text = "Start trip"
	_update_map_controls()
	button_container.show()
	items.finished_trip()
	animation_player.play("start_sound")

func start_run():
	animation_player.play("game_sound")
	button_container.hide()
	start_button.hide()
	map.start_game()
	_update_map_controls()
	process_timer.start()

func do_process():
	match process:
		Process.ITEMS:
			if not items.process_items():
				process = Process.RUN
				do_process()
			else:
				process_timer.start()
		Process.RUN:
			if items.has_died():
				items.check_death()
				start_button.show()
				start_button.text = "Retry trip"
				return
			
			if map.has_reached_end():
				items.use_up_food()
				map.increase_terrain()
				start_button.show()
				start_button.text = "Next trip"
				return
			
			map.step_next()
			var step = items.take_step(get_weather(), map.get_current_terrain())
			day_time += step

			if not items.items.is_empty():
				process = Process.ITEMS
	
			process_timer.start()

# Jungle - Wild Animals, Throns, Slower
# Mountain - Cold, Rocks, Slower
# River - Drink, Slower(Rain)
# Plains

# Hot - Thirst
# Rain - Less Thirst, River, Cold
# Thunder - Less Thirst, River, Cold, Thunder
# Sunny

# 200, Armor - Block, Weight
# 150, Clothes - Warm, Thrist(Hot)
# 120, Gloves - Speed, Less Injury
# 100, Boots - Speed
# 70, Herbs - Health
# 50, Sweets - Hunger, persist
# 30, Food - Hunger
# 30, Water - Thirst
