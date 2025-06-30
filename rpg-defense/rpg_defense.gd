extends Node3D

@export var game_over_ui: Control
@export var paused_ui: Control
@export var money_label: Label
@export var map: GameMap
@export var player: PhysicsPlayer

@onready var main_base: MainBase = $MainBase
@onready var enemy_spawner: EnemySpawner = $EnemySpawner

var money := 0:
	set(v):
		money = v
		money_label.text = "%s$" % money

func _ready() -> void:
	self.money = money
	main_base.died.connect(func(): game_over_ui.show())
	enemy_spawner.enemy_killed.connect(func(): money += 10)

	player.placed_block.connect(func(res: BlockResource, coord: Vector3i):
		if money >= res.cost:
			money -= res.cost
			map.place_block(res, coord)
		else:
			print("Not enough money to place block: %s" % BlockResource.Type.keys()[res.type])
	)
	
	game_over_ui.hide()
	paused_ui.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		paused_ui.show()
	elif event.is_action_pressed("ui_accept") and not enemy_spawner.is_active():
		enemy_spawner.start_wave()
