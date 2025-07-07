class_name Skeleton
extends PhysicsCharacter

signal died()

@export var base_damage := 1
@export var navigation_agent_3d: GridNavigation
@export var enemy: EnemyResource

@onready var animation_tree: SkeletonAnimation = $PlayerAnimation
@onready var hit_box: Area3D = $Body/HitBox
@onready var hurtbox: HurtBox = $Hurtbox
@onready var soft_push: SoftPush = $SoftPush
@onready var death_timer: Timer = $DeathTimer

@onready var map: GameMap = get_tree().get_first_node_in_group("map")

var target: Node3D
var attacking := false
var has_died := false

func _ready() -> void:
	if enemy:
		hurtbox.max_health = enemy.health
		base_damage = enemy.base_damage
		speed_multiplier = enemy.speed
		body.add_child(enemy.enemy_scene.instantiate())

	navigation_agent_3d.target_position = target.global_position
	death_timer.timeout.connect(func(): queue_free())
	
	hit_box.area_entered.connect(func(_a):
		attacking = true
		animation_tree.attack()
	)
	hit_box.area_exited.connect(func(_a): attacking = not hit_box.get_overlapping_areas().is_empty())
	animation_tree.animation_finished.connect(func(name):
		if "_Attack_" in name and attacking:
			animation_tree.attack()
	)
	hurtbox.died.connect(func():
		if not has_died:
			animation_tree.died()
			died.emit()
			has_died = true
			death_timer.start()
	)
	hurtbox.knockbacked.connect(func(force: Vector3):
		apply_central_impulse(force)
	)

func is_dead():
	return has_died

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	apply_central_force(soft_push.get_push_force(get_move_dir()))
	animation_tree.update(body.basis.z, linear_velocity)
	
func get_move_dir():
	if not ground_spring_cast.is_grounded() or attacking or navigation_agent_3d.has_target() or is_dead():
		return Vector3.ZERO

	return global_position.direction_to(navigation_agent_3d.get_target_grid_position())
