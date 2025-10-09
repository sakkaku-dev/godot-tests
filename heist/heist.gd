@tool
class_name Heist
extends Node3D

@export var obstacles: Array[PackedScene] = []
@export var safe_scene: PackedScene
@export var num_of_obstacles := 3

@export var alert_timer: Timer
@export var gameover_ui: Control
@export var unlocked_ui: Control

@export var hacker_room: Node3D
@export var player: CharacterBody3D
@export var hacker_spawn: Node3D
@export var root: Node3D
@export var run := false:
	set(v):
		run = v
		if Engine.is_editor_hint() and run:
			_generate_heist()
		elif Engine.is_editor_hint() and not run:
			for child in root.get_children():
				child.queue_free()

var logger := KumaLog.new("Heist")

func _ready() -> void:
	if GameManager.is_hacker:
		player.global_position = hacker_spawn.global_position
	
	hacker_room.visible = GameManager.is_hacker
	get_tree().paused = false
	gameover_ui.hide()

	_generate_heist(GameManager.seed)
	alert_timer.timeout.connect(func(): gameover_ui.show())

func _generate_heist(_seed = 0):
	var rng = RandomNumberGenerator.new()
	rng.seed = _seed

	var available_obstacles = obstacles.duplicate()
	var previous_obstacle = null
	for i in range(num_of_obstacles):
		if available_obstacles.is_empty():
			break

		var obstacle_scene = available_obstacles[rng.randi_range(0, available_obstacles.size() - 1)]
		available_obstacles.erase(obstacle_scene)

		var obstacle_instance = obstacle_scene.instantiate() as Obstacle
		obstacle_instance.seed = rng.seed + i
		obstacle_instance.failed.connect(func(): _start_alert())
		root.add_child(obstacle_instance)
		
		if previous_obstacle:
			_connect_to(previous_obstacle, obstacle_instance)
		previous_obstacle = obstacle_instance
		
	var safe_instance = safe_scene.instantiate() as Safe
	safe_instance.seed = rng.seed
	safe_instance.unlocked.connect(func(): _safe_unlocked())

	root.add_child(safe_instance)
	_connect_to(previous_obstacle, safe_instance)

func _safe_unlocked():
	GameManager.money_in_millions += randi_range(1, 5)
	logger.info("Heist successful! Stole $%d million!" % GameManager.money_in_millions)
	unlocked_ui.open(GameManager.money_in_millions)

func _start_alert():
	if alert_timer.is_stopped():
		alert_timer.start()

func _connect_to(obstacle: Obstacle, node: Node3D) -> void:
	var points = obstacle.get_connection_points()
	if points.is_empty():
		return

	var point = points[0]
	node.global_transform = point.global_transform
