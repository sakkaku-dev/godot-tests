extends CharacterBody3D

@export var speed := 8.0
@export var max_speed := 20.0
@export var start_height := 50

var falling := true

func _ready() -> void:
	global_position.y = start_height

func _physics_process(delta: float) -> void:
	if not falling: return
	
	velocity.y -= speed
	velocity.y = max(velocity.y, -max_speed)
	
	if move_and_slide():
		falling = false
