extends CharacterBody3D

@export var region: NavigationRegion3D
@export var speed := 5.0
@export var body: Node3D

@onready var wander_timer: RandomTimer = $WanderTimer
@onready var idle_timer: RandomTimer = $IdleTimer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast

var target: Vector3
var gravity = 50

func _ready() -> void:
	wander_timer.timeout.connect(func(): idle_timer.random_start())
	idle_timer.timeout.connect(func(): _start_wander())
	idle_timer.start()

func _start_wander():
	navigation_agent_3d.target_position = NavigationServer3D.map_get_random_point(region.get_navigation_map(), 1, false)
	wander_timer.random_start()

func _physics_process(delta: float) -> void:
	if wander_timer.is_stopped():
		velocity.x = move_toward(velocity.x , 0, 10 * delta)
		velocity.z = move_toward(velocity.z , 0, 10 * delta)
		return
	
	if not navigation_agent_3d.is_navigation_finished() and is_grounded():
		var next_path_position = navigation_agent_3d.get_next_path_position()
		next_path_position.y = global_position.y

		var new_velocity = global_position.direction_to(next_path_position) #* data.speed
		if new_velocity:
			var face_dir = new_velocity
			face_dir.y = 0
			body.basis = Basis.looking_at(-face_dir)

		velocity = new_velocity * speed

	if not is_grounded():
		velocity.y -= gravity * delta
	else:
		var f = ground_spring_cast.apply_spring_force(velocity)
		velocity.y += f.y
	
	move_and_slide()

func is_grounded():
	return ground_spring_cast.is_grounded() #or is_on_floor()
