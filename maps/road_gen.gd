@tool
class_name RoadGen
extends Node3D

const NEIGHBORS = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT]

@export var run := false:
	set(v):
		generate()
		print("Run")
		
@export var grid_size := Vector3(6, 6, 6)
@export var tiles := Vector2i(10, 10)

@export_category("Items")
@export var road_scene: PackedScene
@export var pavement_scene: PackedScene
@export var side_pavement_scene: PackedScene
@export var corner_pavement_scene: PackedScene
@export var building_scene: PackedScene
@export var crossing_scene: PackedScene

@export_category("Generation Road")
@export var min_size_for_split := 7
@export var split_road_size := 10
@export var main_road_chance_decrease := 0.8
@export var pavement_height := 0.1

@export_category("Generation Building")
@export var building_start := 1
@export var min_building := 4
@export var max_building := 15
@export var building_merge_chance_decrease := 0.5

var height: int = 0

var grid_rect: Rect2i
var tile_objects: Dictionary = {}
var deco_objects: Dictionary = {}

func generate():
	_reset()
	grid_rect = Rect2i(Vector2i(1, 0), tiles)
	
	_fill_with_pavement()
	var sections = _generate_roads(grid_rect, true, 1.0)
	_match_pavement_corners()
	_create_static_body()
	#_fill_with_buildings(sections)

func _create_static_body():
	var static_body = StaticBody3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(tiles.x, 0, tiles.y) * grid_size + Vector3.UP
	collision.shape = shape
	static_body.add_child(collision)
	var c = grid_rect.get_center() + Vector2i.LEFT
	static_body.position = Vector3(c.x, 0, c.y) * grid_size + Vector3.DOWN/2 + Vector3.DOWN * pavement_height
	add_child(static_body)
	
	collision.owner = owner
	static_body.owner = owner

func _add_scene(scene: PackedScene, pos: Vector3, angle = 0, remove_existing = true):
	if pos in tile_objects and remove_existing:
		if is_instance_valid(tile_objects[pos]):
			tile_objects[pos].queue_free()
		tile_objects.erase(pos)
	
	var node = scene.instantiate()
	node.position = pos * grid_size
	
	if scene == road_scene:
		node.position.y -= pavement_height
	
	node.rotation_degrees.y = angle
	node.position += get_angle_offset(angle) * grid_size
	
	add_child(node)
	node.owner = owner
	
	if not pos in tile_objects:
		tile_objects[pos] = node
	return node

static func get_angle_offset(angle: float):
	var offset = Vector3.ZERO
	if angle == -90:
		offset = Vector3(0, 0, 1)
	elif angle == 90:
		offset = Vector3(-1, 0, 0)
	elif angle == 180:
		offset = Vector3(-1, 0, 1)
	return offset

func _reset():
	for child in get_children():
		child.queue_free()
	tile_objects = {}
	deco_objects = {}

func _fill_with_pavement():
	var start = grid_rect.position
	for x in grid_rect.size.x:
		for z in grid_rect.size.y:
			_add_scene(pavement_scene, Vector3i(start.x + x, height, start.y + z))

func _generate_roads(rect: Rect2i, vertical := true, main_road_chance := 1.0, generate_chance := 1.0):
	var split_dir = Vector2i.RIGHT if vertical else Vector2i.DOWN
	var length = (rect.size * split_dir).length()
	if length < min_size_for_split: return [rect] # rect.size.x < min_size_for_split or rect.size.y < min_size_for_split: return
	
	var center = rect.get_center()
	var start = rect.position
	var main_road := randf() <= main_road_chance
	var next_main_road_chance := main_road_chance * main_road_chance_decrease
	var half_offset = randi_range(0, 3) if length >= 10 else 0
	
	if half_offset < 0: return [rect]
	
	var next_pos_top := rect.position
	var result = []
	
	if vertical:
		var offset = randi_range(-half_offset, half_offset)
		var half_y = floor(rect.size.y / 2.0)
		var next_pos_bot = Vector2i(rect.position.x, center.y + 1 + offset)
		var next_size_top = Vector2i(rect.size.x, half_y + offset)
		var next_size_bot = Vector2i(rect.size.x, half_y - offset)
		if rect.size.y % 2 == 0:
			next_size_bot.y -= 1
		if main_road:
			next_size_top.y -= 1
		
		for x in rect.size.x:
			var pos = Vector3i(start.x + x, height, center.y + offset)
			var b = Basis.looking_at(Vector3.FORWARD)
			_add_scene(road_scene, pos)
			if main_road:
				_add_scene(road_scene, pos + Vector3i(0, 0, -1))
	
		var next_top_rect = Rect2i(next_pos_top, next_size_top)
		var next_bot_rect = Rect2i(next_pos_bot, next_size_bot)
		if randf() <= generate_chance or next_size_top.x >= split_road_size:
			result.append_array(_generate_roads(next_top_rect, not vertical, next_main_road_chance, generate_chance * 0.8))
		else:
			result.append(next_top_rect)
			
		if randf() <= generate_chance or next_size_bot.x >= split_road_size:
			result.append_array(_generate_roads(next_bot_rect, not vertical, next_main_road_chance, generate_chance * 0.8))
		else:
			result.append(next_bot_rect)
	
	else:
		var offset = randi_range(-half_offset, half_offset)
		var half_x = floor(rect.size.x / 2.0)
		var next_pos_bot = Vector2i(center.x + 1 + offset, rect.position.y)
		var next_size_top = Vector2i(half_x + offset, rect.size.y)
		var next_size_bot = Vector2i(half_x - offset, rect.size.y)
		if rect.size.x % 2 == 0:
			next_size_bot.x -= 1
		if main_road:
			next_size_top.x -= 1
		
		for y in rect.size.y:
			var pos = Vector3i(center.x + offset, height, start.y + y)
			var b = Basis.looking_at(Vector3.RIGHT)
			_add_scene(road_scene, pos)
			if main_road:
				_add_scene(road_scene, pos + Vector3i(-1, 0, 0))
	
		var next_top_rect = Rect2i(next_pos_top, next_size_top)
		var next_bot_rect = Rect2i(next_pos_bot, next_size_bot)
		if randf() <= generate_chance or next_size_top.y >= split_road_size:
			result.append_array(_generate_roads(Rect2i(next_pos_top, next_size_top), not vertical, next_main_road_chance, generate_chance * 0.8))
		else:
			result.append(next_top_rect)
		if randf() <= generate_chance or next_size_bot.y >= split_road_size:
			result.append_array(_generate_roads(Rect2i(next_pos_bot, next_size_bot), not vertical, next_main_road_chance, generate_chance * 0.8))
		else:
			result.append(next_bot_rect)
	
	return result

func _match_pavement_corners():
	for c in tile_objects.keys():
		var cell_item = tile_objects[c] as RoadItem
		if cell_item and cell_item.type != RoadItem.Type.PAVEMENT: continue
		
		var roads = NEIGHBORS.filter(func(d): return (c + d) in tile_objects).map(func(dir): return [tile_objects[c + dir], dir]).filter(func(i): return i[0] is RoadItem and i[0].type == RoadItem.Type.ROAD)
		if roads.is_empty(): continue
		
		var first_dir = roads[0][1]
		var second_dir = roads[1][1] if roads.size() > 1 else null
			
		var angle = 0
		if first_dir == Vector3.LEFT:
			angle = -90
		elif first_dir == Vector3.RIGHT:
			angle = 90
		elif first_dir == Vector3.FORWARD:
			angle = 180
		if second_dir:
			if second_dir.x < 0 and first_dir.z < 0:
				angle = -90
			
		var scene = side_pavement_scene if roads.size() == 1 else corner_pavement_scene
		if second_dir:
			_add_scene(road_scene, c, 0, false)
			
			#var center_dir = first_dir + second_dir
			#var cross = crossing_scene.instantiate()
			#for a in [-90, 90]:
				#var pos = Vector3(c).rotated(Vector3.UP, deg_to_rad(a))
				#if pos in deco_objects: continue
				#
				#cross.position = pos * Vector3(grid_size)
				#add_child(cross)
				#deco_objects[pos] = cross
		
		#if second_dir:
			#print("%s - %s" % [dir, rad_to_deg(dir.angle_to(Vector3.FORWARD))])
		_add_scene(scene, c, angle)

func _fill_with_buildings(sections: Array):
	var noise = FastNoiseLite.new()
	var buildings = []
	
	for sec in sections:
		var region = sec as Rect2i
		var build_area = region.grow(-1)
		var pos = build_area.position
		
		if not build_area.has_area() or build_area.size.x == 1 or build_area.size.y == 1: continue
		
		#var merge_next := false
		#var building_type := -1
		#var height = 0
		#var depth = 0
		#var merge_chance := 0.5
		
		var building = building_scene.instantiate() as BuildingGen
		
		building.tiles = Vector3(build_area.size.x, randi_range(min_building, max_building), build_area.size.y) * grid_size / building.get_tile_size()
		add_child(building)
		building.position = Vector3(pos.x, 0, pos.y) * grid_size
		#building.owner = owner
		building.generate()
