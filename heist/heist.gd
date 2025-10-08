@tool
class_name Heist
extends Node3D

@export var obstacles: Array[PackedScene] = []
@export var safe_scene: PackedScene
@export var num_of_obstacles := 3
@export var alert_timer: Timer
@export var gameover_ui: Control

@export var root: Node3D
@export var run := false:
	set(v):
		run = v
		if Engine.is_editor_hint() and run:
			_generate_heist()
		elif Engine.is_editor_hint() and not run:
			for child in root.get_children():
				child.queue_free()

var seed := 0

func _ready() -> void:
	get_tree().paused = false
	gameover_ui.hide()

	_generate_heist()
	alert_timer.timeout.connect(func(): gameover_ui.show())

func _generate_heist():
	seed = randi()

	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var available_obstacles = obstacles.duplicate()
	var previous_obstacle = null
	for i in range(num_of_obstacles):
		if available_obstacles.is_empty():
			break

		var obstacle_scene = available_obstacles[rng.randi_range(0, available_obstacles.size() - 1)]
		available_obstacles.erase(obstacle_scene)

		var obstacle_instance = obstacle_scene.instantiate() as Obstacle
		obstacle_instance.seed = seed + i
		obstacle_instance.failed.connect(func(): _start_alert())
		root.add_child(obstacle_instance)
		
		if previous_obstacle:
			_connect_to(previous_obstacle, obstacle_instance)
		previous_obstacle = obstacle_instance
		
	var safe_instance = safe_scene.instantiate()
	root.add_child(safe_instance)
	_connect_to(previous_obstacle, safe_instance)

func _start_alert():
	if alert_timer.is_stopped():
		alert_timer.start()

func _connect_to(obstacle: Obstacle, node: Node3D) -> void:
	var points = obstacle.get_connection_points()
	if points.is_empty():
		return

	var point = points[0]
	node.global_transform = point.global_transform
