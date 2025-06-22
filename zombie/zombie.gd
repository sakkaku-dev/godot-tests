extends CharacterBody3D

@export var region: NavigationRegion3D
@export var speed := 30.0
@export var body: Node3D

@onready var wander_timer: RandomTimer = $WanderTimer
@onready var idle_timer: RandomTimer = $IdleTimer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

var target: Vector3

func _ready() -> void:
	wander_timer.timeout.connect(func():
		navigation_agent_3d.target_position = global_position
		idle_timer.random_start()
	)
	
	_start_wander()

func _start_wander():
	navigation_agent_3d.target_position = NavigationServer3D.map_get_random_point(region.get_navigation_map(), 0, false)
	wander_timer.random_start()

func _physics_process(delta: float) -> void:
	if navigation_agent_3d.is_navigation_finished() or not is_on_floor():
		return
		
	var next_path_position = navigation_agent_3d.get_next_path_position()
	next_path_position.y = global_position.y
	
	var new_velocity = global_position.direction_to(next_path_position) #* data.speed
	if new_velocity:
		var face_dir = new_velocity
		face_dir.y = 0
		body.basis = Basis.looking_at(face_dir)
	
	velocity = new_velocity * speed
	move_and_slide()
