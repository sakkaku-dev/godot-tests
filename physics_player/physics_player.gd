class_name PhysicsPlayer
extends PhysicsCharacter

signal player_ready()

const GROUP = "PLAYER"

@export var menu: RadialMenu
@export var player_input: PlayerInput
@export var color_ring: ColorRect
@export var label: Label3D
@export var pickup_area: Area3D

var color := Color.WHITE
var is_aiming := false

var held_object: Item = null:
	set(v):
		held_object = v
		label.text = str(v.item_name) if v else ""

var working_station: Station = null

func _enter_tree() -> void:
	set_multiplayer_authority(int(name.split("_")[0]))

func _ready() -> void:
	add_to_group(GROUP)
	color_ring.color = color
	
	var is_authority = is_multiplayer_authority()
	set_process_unhandled_input(is_authority)
	set_physics_process(is_authority)
	if not is_authority: return
	
	var parts = name.split("_")
	player_input.set_for_id(parts[1])
	player_input.just_pressed.connect(func(ev):
		if ev.is_action_pressed("ready"):
			if DungeonGame.is_prepping():
				player_ready.emit()
		elif ev.is_action_pressed("interact"):
			if held_object:
				try_put_down()
			else:
				try_pick_up()
		elif ev.is_action_pressed("work"):
			var nearest_object = get_nearest_object(false)
			if not DungeonGame.is_prepping() and nearest_object.can_do_work():
				working_station = nearest_object
				working_station.start_work()
				print("Working on station %s" % working_station)
		elif ev.is_action_pressed("rotate") and held_object is Station:
			rotate_held_station()

	)
	player_input.just_released.connect(func(ev: InputEvent):
		if ev.is_action_released("work") and working_station:
			working_station.stop_work()
			working_station = null
			print("Stopped working on station %s" % working_station)
	)

func get_move_dir():
	if menu and menu.visible: return Vector3.ZERO
	if working_station: return Vector3.ZERO

	var motion = player_input.get_vector("move_right", "move_left", "move_down", "move_up")
	var move_dir = Vector3(motion.x, 0, motion.y)
	if move_dir.length() > 1:
		move_dir = move_dir.normalized()
	return move_dir

func get_aim_dir():
	if menu and menu.visible: return Vector3.ZERO
	if not is_aiming: return Vector3.ZERO
	if working_station: return Vector3.ZERO

	var aim = player_input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim: return Vector3(aim.x, 0, aim.y)
	
	return _get_mouse_direction()

func _get_mouse_direction():
	var screen_pos = get_viewport().get_camera_3d().unproject_position(body.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos) - PI
	return Vector3.RIGHT.rotated(Vector3.UP, -angle)

@rpc("any_peer", "call_local", "reliable")
func rotate_held_station():
	if held_object is Station:
		held_object.rotate_step()

@rpc("any_peer", "call_local", "reliable")
func try_pick_up():
	var nearest_object = get_nearest_object()
	print("Try picking up object %s" % nearest_object)
	if nearest_object:
		held_object = nearest_object.pick_up(pickup_area)

func get_nearest_object(find_items = true, find_stations = true):
	var nearest_object: Node = null
	var nearest_distance: float = INF
	
	for area in pickup_area.get_overlapping_areas():
		var distance = global_position.distance_to(area.global_position)
		if distance < nearest_distance:
			if area is Station and area.is_pickupable() and find_stations:
				nearest_object = area
				nearest_distance = distance
			elif area is Ingredient and area.is_pickupable() and find_items:
				nearest_object = area
				nearest_distance = distance
	
	return nearest_object

@rpc("any_peer", "call_local", "reliable")
func try_put_down():
	if held_object:
		print("Try putting down object %s" % held_object)

		if held_object is Station:
			var snapped_pos = held_object.snap_to_grid(global_position + body.basis.z)
			if snapped_pos:
				held_object.put_down(snapped_pos)
				held_object = null
		elif held_object is Ingredient:
			for area in pickup_area.get_overlapping_areas():
				if area is Dish:
					held_object = area.put_item(held_object)
				elif area is Station:
					if area.put_item(held_object):
						held_object = null
						return
			
