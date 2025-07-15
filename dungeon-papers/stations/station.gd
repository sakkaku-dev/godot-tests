class_name Station
extends Item

@export var processing_time: float = 2.0
@export var automatic := false

var current_item: Ingredient = null
var is_working: bool = false:
	set(v):
		is_working = v and has_item_to_work()
		if is_working:
			circle_timer.start(processing_time)
		else:
			circle_timer.stop()

@onready var item_position: Marker3D = $ItemPosition
@onready var circle_timer: CircleTimer = $CircleTimer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var dungeon_map: DungeonMap = get_tree().get_first_node_in_group(DungeonMap.GROUP)

func _ready() -> void:
	super._ready()
	if circle_timer:
		circle_timer.finished.connect(func(): finish_processing())

@rpc("any_peer", "call_local", "reliable")
func pick_up(holder: Node3D):
	if DungeonGame.is_prepping():
		var item = super.pick_up(holder)
		collision_shape.disabled = true
		return item
	elif current_item:
		var item = current_item.pick_up(holder)
		item.enable_pickup()
		reset()
		return item

@rpc("any_peer", "call_local", "reliable")
func put_down(new_position: Vector3):
	super.put_down(new_position)
	collision_shape.disabled = false

func snap_to_grid(pos: Vector3) -> Vector3:
	return dungeon_map.get_snapped_position(pos)

func can_place_at(pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = collision_shape.shape
	query.transform = Transform3D(Basis.IDENTITY, snap_to_grid(pos))
	query.collide_with_bodies = true
	query.collision_mask = collision_mask
	
	var results = space_state.intersect_shape(query)
	return results.is_empty()

func can_do_work() -> bool:
	return not is_working and has_item_to_work() and processing_time > 0

func has_item_to_work() -> bool:
	return current_item != null and current_item.can_station_process(self)

func rotate_step():
	rotation.y += PI/2

func put_item(item: Item):
	if current_item: return false

	current_item = item
	move_item(item, self)
	if item_position:
		item.position = item_position.position
	item.disable_pickup()
	is_working = automatic and can_do_work()
	return true

func finish_processing():
	if not current_item: return

	var output_scene = current_item.get_output_for_station(self)
	current_item.queue_free()
	reset()

	if output_scene:
		var new_item = output_scene.instantiate() as Item
		new_item.pick_up(self)
		if item_position:
			new_item.position = item_position.position
		new_item.disable_pickup()
		current_item = new_item

func start_work():
	if processing_time <= 0: return
	is_working = true
	
func stop_work():
	if processing_time <= 0: return
	is_working = false

func reset():
	current_item = null
	is_working = false
