class_name EnemySpawner
extends Node3D

signal wave_ended()
signal enemy_killed()

@export var destination: Node3D
@export var enemy_scene: PackedScene
@export var spawn_timer: Timer
@export var wave_timer: Timer

@export_category("UI")
@export var wave_label: Label
@export var wave_time_label: Label

@export_category("Difficulty")
@export var base_spawn_time := 5.0
@export var min_base_spawn_time := 0.5

var wave := 0:
	set(v):
		wave = v
		wave_label.text = "Wave %s" % wave
	
var alive_enemy_count := 0:
	set(v):
		alive_enemy_count = v
		_check_wave_ended()

var difficulty := 1.0

func _ready() -> void:
	wave_label.hide()
	spawn_timer.timeout.connect(func(): _spawn_enemy())
	wave_timer.timeout.connect(func(): finish_wave())

func _process(delta: float) -> void:
	wave_time_label.visible = not wave_timer.is_stopped()
	wave_time_label.text = "%0.fs" % wave_timer.time_left

func _spawn_enemy():
	alive_enemy_count += 1
	var enemy = enemy_scene.instantiate()
	enemy.target = destination
	enemy.position = global_position
	enemy.died.connect(func():
		enemy_killed.emit()
		alive_enemy_count -= 1
	)
	get_tree().current_scene.add_child(enemy)

func is_active():
	return not wave_timer.is_stopped()

func start_wave():
	wave += 1
	alive_enemy_count = 0
	spawn_timer.start(max(base_spawn_time / difficulty, min_base_spawn_time))
	wave_timer.start()
	wave_label.show()
	
func finish_wave():
	spawn_timer.stop()
	_check_wave_ended()

func _check_wave_ended():
	if wave_timer.is_stopped() and alive_enemy_count <= 0:
		difficulty += 1.0
		wave_label.hide()
		wave_ended.emit()
