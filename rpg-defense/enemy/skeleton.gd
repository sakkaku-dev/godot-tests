class_name Skeleton
extends PhysicsCharacter

signal died()

@export var base_damage := 1
@onready var animation_tree: PlayerAnimation = $PlayerAnimation
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var hit_box: Area3D = $Body/HitBox
@onready var hurtbox: HurtBox = $Hurtbox

var target: Node3D
var attacking := false

func _ready() -> void:
	navigation_agent_3d.target_position = target.global_position
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
		died.emit()
		queue_free()
	)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	animation_tree.update(body.basis.z, linear_velocity)

func get_move_dir():
	if navigation_agent_3d.is_navigation_finished() or not ground_spring_cast.is_grounded() or attacking:
		return Vector3.ZERO
		
	var next_path_position = navigation_agent_3d.get_next_path_position()
	next_path_position.y = global_position.y
	
	return global_position.direction_to(next_path_position) 
