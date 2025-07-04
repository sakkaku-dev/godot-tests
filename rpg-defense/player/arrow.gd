extends Node3D

@export var speed := 10.0
@export var dir := Vector3.BACK

@onready var hit_box: HitBox = $HitBox

func _ready() -> void:
	hit_box.area_entered.connect(func(_x):
		hit_box.do_hit()
		queue_free()
	)
	hit_box.body_entered.connect(func(_x): queue_free())

func _physics_process(delta: float) -> void:
	translate(dir * speed * delta)
