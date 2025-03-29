class_name ZipLine
extends CharacterBody3D

@export var projectile_speed := 30.0

@onready var path_3d: Path3D = $Path3D
@onready var end_interact: Area3D = $EndInteract
@onready var start_pole: CSGBox3D = $StartPole
@onready var body: Node3D = $Body

@onready var gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * Vector3.DOWN
@onready var start: Vector3 = global_position

var move_dir := Vector3.FORWARD

func _ready() -> void:
	#move_dir = move_dir * global_basis
	print(move_dir)
	start_pole.hide()

func _physics_process(delta: float) -> void:
	if not move_dir: return
	
	velocity = move_dir * projectile_speed
	#velocity += gravity
	
	body.basis = Basis.looking_at(velocity)
	
	if move_and_slide():
		_on_landing()

func _on_landing():
	move_dir = Vector3.ZERO
	
	var curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(to_local(start))
	path_3d.curve = curve
	
	start_pole.position = curve.get_point_position(curve.point_count - 1)
	start_pole.show()
