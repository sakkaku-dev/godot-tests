extends Node3D

@export var damage := 10.0
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var fire_area: Area3D = $FireArea

func _ready() -> void:
	fire_area.body_entered.connect(func(_b): fire_at_closest_enemy())
	fire_rate_timer.timeout.connect(func(): fire_at_closest_enemy())

func fire_at_closest_enemy():
	var enemy = get_closest_enemy()
	if enemy is PhysicsCharacter:
		enemy.fire_effect.apply(damage)
		fire_rate_timer.start()
	
func get_closest_enemy():
	var closest_dist = INF
	var closest_enemy = null

	for enemy in fire_area.get_overlapping_bodies():
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_enemy = enemy
	
	return closest_enemy
