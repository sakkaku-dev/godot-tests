@tool
class_name RoadGenerator
extends GridMap

const NEIGHBORS = [Vector3i.FORWARD, Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT]
const BUILDINGS = [4, 5, 6]
const BOT_BUILDING = [preload("res://maps/building_bot.tscn")]

#const BUILDING_MAT = {
	#4: preload("res://assets/textures/Stenciled Brick Floor/1k/Stenciled Brick Floor.tres"),
	#5: preload("res://assets/textures/Square Tiles/1k/Square Tiles.tres"),
	#6: preload("res://assets/textures/Painted Plaster Wall/1k/Painted Plaster Wall.tres")
#}

@export var run := false:
	set(v):
		generate()

@export_category("Items")
@export var road_item := 0
@export var road_wide_item := 8
@export var road_empty := 9
@export var pavement_item := 1
@export var pavement_side := 1
@export var pavement_corner := 1
@export var building_scene: PackedScene

@export_category("Generation")
@export var grid_size := Vector2i(0, 0)
@export var height := 0
@export var min_size_for_split := 7
@export var split_road_size := 10
@export var building_start := 1
@export var min_building := 4
@export var max_building := 15
@export var building_merge_chance_decrease := 0.5
@export var main_road_chance_decrease := 0.5

var grid_rect: Rect2i

func generate():
	_reset()
	grid_rect = Rect2i(-grid_size / 2, grid_size)
	
	_fill_with_pavement()
	var sections = _generate_roads(grid_rect, true, 0.0)
	_match_pavement_corners()
	_match_road_types()
	#_fill_with_buildings(sections)

func _reset():
	clear()
	for child in get_children():
		child.queue_free()

func _fill_with_pavement():
	var start = grid_rect.position
	for x in grid_rect.size.x:
		for z in grid_rect.size.y:
			set_cell_item(Vector3i(start.x + x, height, start.y + z), pavement_item)


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
			set_cell_item(pos, road_item, get_orthogonal_index_from_basis(b))
			if main_road:
				set_cell_item(pos + Vector3i(0, 0, -1), road_item, get_orthogonal_index_from_basis(b))
	
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
			set_cell_item(pos, road_item, get_orthogonal_index_from_basis(b))
			if main_road:
				set_cell_item(pos + Vector3i(-1, 0, 0), road_item, get_orthogonal_index_from_basis(b))
	
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
	for c in get_used_cells():
		var cell_item = get_cell_item(c)
		if cell_item != pavement_item: continue
		
		var roads = NEIGHBORS.map(func(dir): return [get_cell_item(c + dir), dir]).filter(func(i): return i[0] == road_item)
		if roads.is_empty(): continue
		
		var first_dir = roads[0][1] as Vector3i
		var second_dir = roads[1][1] if roads.size() > 1 else null
		
		var dir = Vector3(first_dir).rotated(Vector3.UP, PI/2)
		if second_dir:
			dir = first_dir + second_dir
			dir = Vector3(dir).rotated(Vector3.UP, -PI/4)
	
		var corner_type = pavement_side if roads.size() == 1 else pavement_corner
		var b = Basis.looking_at(dir) if dir.length() > 0 else Basis.IDENTITY
		set_cell_item(c, corner_type, get_orthogonal_index_from_basis(b))

func _match_road_types():
	for c in get_used_cells():
		var cell_item = get_cell_item(c)
		if cell_item != road_item: continue
		
		var pavements = NEIGHBORS.map(func(dir): return [get_cell_item(c + dir), dir]).filter(func(i): return i[0] in [pavement_item, pavement_side, pavement_corner])
		if pavements.size() != 1:
			if pavements.is_empty():
				set_cell_item(c, road_empty)
			continue
		
		var first_dir = pavements[0][1] as Vector3i
		var dir = Vector3(first_dir).rotated(Vector3.UP, PI)
		var corner_type = road_wide_item
		var b = Basis.looking_at(dir)
		set_cell_item(c, corner_type, get_orthogonal_index_from_basis(b))
	

func _fill_with_buildings(sections: Array):
	var noise = FastNoiseLite.new()
	var buildings = []
	
	for sec in sections:
		var region = sec as Rect2i
		var build_area = region.grow(-1)
		var pos = build_area.position
		
		if not build_area.has_area() or build_area.size.x == 1 or build_area.size.y == 1: continue
		
		var merge_next := false
		var building_type := -1
		var height = 0
		var depth = 0
		var merge_chance := 0.5
		
		#var current_size = Rect2i()
		
		var building = building_scene.instantiate() as BuildingGen
		#var max_size = build_area.size * Vector2i(cell_size.x, cell_size.z) / Vector2i(building.get_tile_size().x, building.get_tile_size().z)
		
		building.tiles = Vector2(build_area.size) * Vector2(cell_size.x, cell_size.z) / Vector2(building.get_tile_size().x, building.get_tile_size().z) - Vector2.ONE
		add_child(building)
		building.global_position = map_to_local(Vector3i(pos.x, 0, pos.y))
		building.owner = owner
		building.height = randi_range(min_building, max_building)
		building.generate()
		
		#for x in build_area.size.x:
			#for y in build_area.size.y:
				#if x == 0 or x == build_area.size.x-1 or y == 0 or y == build_area.size.y-1:
					#var dir = Vector3i.RIGHT
					#if x == build_area.size.x-1:
						#dir = Vector3i.LEFT
						#max_size = ceil(max_size)
					#elif y == 0:
						#dir = Vector3i.BACK
					#elif y == build_area.size.y-1:
						#dir = Vector3i.FORWARD
					#
					#max_size = floor(max_size)
					#if not merge_next:
						#var max_length = (max_size * abs(Vector2(dir.x, dir.z))).length()
						#depth = randi_range(2, max_length)
						#if max_length < 2:
							#depth = 1
						#
						#height = randi_range(min_building, max_building)
						#building_type = BUILDINGS.filter(func(b): return b != building_type).pick_random()
						#merge_chance = 0.5
					#else:
						#merge_chance *= building_merge_chance_decrease
					#
					#var b = Basis.looking_at(dir)
					#
					#var is_stopped := false
					#for w in depth:
						#var main_pos = Vector3i(pos.x + x, building_start, pos.y + y) + dir * w
						#for i in height:
							#var p = main_pos + Vector3i.UP * i
							#if get_cell_item(p) != -1:
								#is_stopped = true
							#
							#if is_stopped:
								#break
						#
							#set_cell_item(p, building_type, get_orthogonal_index_from_basis(b))
					#
						#if not is_stopped:
							#var main_building = BOT_BUILDING.pick_random().instantiate() as BuildingBot
							#add_child(main_building)
							#main_building.global_position = map_to_local(Vector3i(main_pos.x, 0, main_pos.z))
							##main_building.global_rotation.y = Vector3(dir).angle_to(Vector3.BACK)
							#main_building.look_at(main_building.global_position + Vector3(dir))
							#if not Engine.is_editor_hint(): # does not work inside editor
								#main_building.set_material(BUILDING_MAT[building_type])
					#
					#merge_next = randf() < merge_chance
