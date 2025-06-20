@tool
class_name BuildingGen
extends Node3D

const WALL_TILE_1 = preload("res://assets/KawaiiCity/Materials/WallTile 1.material")
const WALL_TILE_2 = preload("res://assets/KawaiiCity/Materials/WallTile 2.material")
const WALL_TILE_3 = preload("res://assets/KawaiiCity/Materials/WallTile 3.material")
const WALL_TILE_4 = preload("res://assets/KawaiiCity/Materials/WallTile 4.material")
const WALL_TILE_5 = preload("res://assets/KawaiiCity/Materials/WallTile 5.material")

const MATERIALS = [WALL_TILE_1, WALL_TILE_2, WALL_TILE_3, WALL_TILE_4, WALL_TILE_5]

@export var run := false:
	set(v):
		generate()
@export var random_material := true

@export var door_scene: PackedScene
@export var door_position := 0
@export var material: Material

@export var roof_level: BuildLevelResource
@export var mid_level: BuildLevelResource
@export var floor_level: BuildLevelResource

@export var tile_size := Vector3(3, 3, 3)
@export var tiles := Vector3(2, 5, 2)

@export var corner_bot_left := false
@export var corner_bot_right := false
@export var corner_top_left := false
@export var corner_top_right := false

var facing_dir := Vector3.FORWARD

func get_tile_size():
	return tile_size

func generate():
	for c in get_children():
		c.queue_free()
	
	if random_material:
		material = MATERIALS.pick_random()
	
	var door_min = 1 if corner_bot_right else 0
	var door_max = tiles.x - (2 if corner_bot_left else 1)
	door_position = randi_range(door_min, door_max)
	
	for y in tiles.y:
		for x in tiles.x:
			for z in tiles.z:
				var pos = Vector3(x, y, z)
				var res = floor_level if y == 0 else mid_level
				
				var is_roof = y == tiles.y - 1
				var is_top = z == tiles.z - 1
				var is_bot = z == 0
				var is_right = x == 0
				var is_left = x == tiles.x - 1
				
				if _is_corner(pos):
					if is_bot:
						if corner_bot_left and is_left:
							_add_scene(res.corner_side, pos)
							if is_roof:
								_add_scene(roof_level.corner_side, pos + Vector3.UP + Vector3.BACK)
							continue
						if corner_bot_right and is_right:
							_add_scene(res.corner_side, pos + Vector3.BACK, 90)
							if is_roof:
								_add_scene(roof_level.corner_side, pos + Vector3.UP + Vector3.BACK + Vector3.RIGHT, 90)
							continue
					elif is_top:
						if corner_top_left and is_left:
							_add_scene(res.corner_side, pos + Vector3.RIGHT, -90)
							if is_roof:
								_add_scene(roof_level.corner_side, pos + Vector3.UP, -90)
							continue
						if corner_top_right and is_right:
							_add_scene(res.corner_side, pos + Vector3.RIGHT + Vector3.BACK, 180)
							if is_roof:
								_add_scene(roof_level.corner_side, pos + Vector3.UP + Vector3.RIGHT, 180)
							continue
					
				
				if is_right:
					_place_for_resource(res, pos + Vector3.BACK, Vector3.LEFT)
				if is_left:
					_place_for_resource(res, pos + Vector3.RIGHT, Vector3.RIGHT)
				if is_bot:
					_place_for_resource(res, pos, Vector3.FORWARD)
				if is_top:
					_place_for_resource(res, pos + Vector3.RIGHT + Vector3.BACK, Vector3.BACK)
				
				if is_roof:
					var dir = Vector3.FORWARD
					_place_for_resource(roof_level, Vector3(x, tiles.y, z) - dir, dir)
	
	#_create_static_body()
	#
#func _create_static_body():
	#var static_body = StaticBody3D.new()
	#var collision = CollisionShape3D.new()
	#var shape = BoxShape3D.new()
	#shape.size = tile_size * tiles
	#collision.shape = shape
	#
	#static_body.add_child(collision)
	#add_child(static_body)
	#static_body.position = tile_size * tiles / 2 - Vector3(tile_size.x, 0, tile_size.z) / 2
	#static_body.owner = self
	#collision.owner = self

#func _create_decorations():
	#for deco in deco_res:
		#var min_height = deco.height.x
		#var max_height = deco.height.y
		#if min_height < 0:
			#min_height = 0
		#if max_height < 0:
			#max_height = height
		#
		#for h in range(min_height, max_height):
			#var tile_size = mid_res.tile_size
			#if h == 0:
				#tile_size = bot_res.tile_size
			#elif h >= height:
				#tile_size = top_res.tile_size
			#
			#var align = get_alignment_value(deco)
			#for dir in deco.dirs:
				#var coord = Vector2.ZERO
				#var x = tiles.x - 1
				#var y = tiles.y - 1
				#
				#if dir.dot(Vector2.RIGHT) == 0:
					#coord += Vector2(x * align, y if Vector2.UP.dot(dir) > 0 else 0)
				#else:
					#coord += Vector2(x if Vector2.UP.dot(dir) > 0 else 0, y * align)
				#
				#var pos = Vector3(coord.x, h, coord.y) * tile_size
				#_place_node(deco.scene, pos, [Vector3(dir.x, 0, dir.y)])

func _is_corner(pos: Vector3) -> bool:
	return (pos.x == 0 or pos.x == tiles.x-1) and (pos.z == 0 or pos.z == tiles.z-1)

func _place_for_resource(res: BuildLevelResource, pos: Vector3, dir: Vector3):
	var angle = 0
	var scene = res.front_side
	
	if Vector3.RIGHT == dir:
		angle = -90
		scene = res.left_side
	elif Vector3.BACK == dir:
		angle = 180
		scene = res.back_side
	elif Vector3.LEFT == dir:
		angle = 90
		scene = res.right_side
		
	if door_scene and dir == Vector3.FORWARD and pos == Vector3(door_position, 0, 0):
		scene = door_scene
	
	return _add_scene(scene, pos, angle)

func _add_scene(scene: PackedScene, pos: Vector3, angle = 0):
	if scene == null:
		return null
	
	pos.x *= -1
	pos.z *= -1
	
	var node = scene.instantiate()
	node.position = pos * tile_size
	node.rotation_degrees.y = angle
	
	add_child(node)
	
	if node is DynamicWallMaterial:
		node.set_wall_material(material)
	
	node.owner = owner
	return node
