extends CharacterBody3D

@export var region: NavigationRegion3D
@export var speed := 5.0
@export var body: Node3D
@export var vision: Area3D

@onready var wander_timer: RandomTimer = $WanderTimer
@onready var idle_timer: RandomTimer = $IdleTimer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast

var target: Vector3
var gravity = 50

var player_target: Node3D
var last_player_position

func _ready() -> void:
	wander_timer.timeout.connect(func():
		idle_timer.random_start()
		print("Start idling")
	)
	idle_timer.timeout.connect(func():
		_start_wander()
	)
	idle_timer.start()
	
	vision.body_entered.connect(func(b):
		if not player_target:
			player_target = b
			wander_timer.stop()
			idle_timer.stop()
			print("Chase player %s" % b)
	)
	vision.body_exited.connect(func(b):
		if player_target == b:
			player_target = null
			navigation_agent_3d.target_position = last_player_position
			print("Lost player at %s" % last_player_position)
	)

func _start_wander():
	navigation_agent_3d.target_position = NavigationServer3D.map_get_random_point(region.get_navigation_map(), 1, false)
	wander_timer.random_start()
	print("Start wandering")

func _process(delta: float) -> void:
	if player_target:
		last_player_position = player_target.global_position

func _physics_process(delta: float) -> void:
	if player_target and last_player_position != null:
		_player_follow()
	else:
		_wander(delta)
	
	if _do_navigation():
		if last_player_position != null:
			last_player_position = null
			idle_timer.start()
			print("No player at last position %s" % last_player_position)
	
	_apply_gravity(delta)
	move_and_slide()

func _player_follow():
	if player_target:
		navigation_agent_3d.target_position = player_target.global_position

func _wander(delta: float):
	if wander_timer.is_stopped():
		velocity.x = move_toward(velocity.x , 0, 10 * delta)
		velocity.z = move_toward(velocity.z , 0, 10 * delta)
		return

func _do_navigation():
	if not navigation_agent_3d.is_navigation_finished() and is_grounded():
		var next_path_position = navigation_agent_3d.get_next_path_position()
		next_path_position.y = global_position.y

		var new_velocity = global_position.direction_to(next_path_position) #* data.speed
		if new_velocity:
			var face_dir = new_velocity
			face_dir.y = 0
			body.basis = Basis.looking_at(-face_dir)

		velocity = new_velocity * speed

	return navigation_agent_3d.is_navigation_finished()

func _apply_gravity(delta: float):
	if not is_grounded():
		velocity.y -= gravity * delta
	else:
		var f = ground_spring_cast.apply_spring_force(velocity)
		velocity.y += f.y

func is_grounded():
	return ground_spring_cast.is_grounded() #or is_on_floor()
