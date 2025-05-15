@tool
class_name ExpeditionMap
extends Control

signal marked()

@export var run := false:
	set(v):
		generate_map()

@export var node_height_dist = 50.0
@export var node_radius = 5.0
@export var depth = 4
@export var max_height = 2
@export var extra_edges = 3

@export var point_scene: PackedScene

enum Location {
	NONE,
	CITY,
	HOSPITAL,
	CHEST,
}

const LOCATION_TEXTURE = {
	Location.NONE: preload("res://assets/Free Paper UI System/1 Sprites/Content/5 Holders/8.png"),
	Location.CITY: preload("res://assets/Free Paper UI System/1 Sprites/Content/2 Icons/13.png"),
	Location.HOSPITAL: preload("res://assets/Free Paper UI System/1 Sprites/Content/2 Icons/15.png"),
	Location.CHEST: preload("res://assets/Free Paper UI System/1 Sprites/Content/2 Icons/12.png"),
}

enum Terrain {
	PLAINS,
	JUNGLE,
	MOUNTAIN,
	RIVER,
}

const TERRAIN_COLOR = {
	Terrain.PLAINS: Color(0.5, 1, 0.5),
	Terrain.JUNGLE: Color(0.2, 0.8, 0.2),
	Terrain.MOUNTAIN: Color(0.7, 0.7, 0.7),
	Terrain.RIVER: Color(0.2, 0.4, 1),
}

var terrains = [Terrain.PLAINS, Terrain.MOUNTAIN]
var terrain_chances = {
	Terrain.PLAINS: 0.5,
	Terrain.JUNGLE: 0.2,
	Terrain.MOUNTAIN: 0.2,
	Terrain.RIVER: 0.1,
}

var dirty := false
var nodes = []
var edges = []

var path := []

func _ready() -> void:
	generate_map()

func generate_map():
	dirty = true
	path = []

	generate_nodes()
	connect_nodes()
	add_extra_edges()
	queue_redraw()

func _draw() -> void:
	var y_offset = size.y/10
	var x_diff = size.x / depth
	var y_center = size.y / 2 + y_offset

	for edge in edges:
		var a = edge.a
		var b = edge.b
		var p1 = Vector2((a.x + 0.5) * x_diff, y_center + node_height_dist * a.y)
		var p2 = Vector2((b.x + 0.5) * x_diff, y_center + node_height_dist * b.y)
		#draw_line(p1, p2, TERRAIN_COLOR[edge.terrain], 2)
		var color = Color.RED if a in path and b in path else Color.DIM_GRAY
		draw_line(p1, p2, color, 2)

	if not dirty: return
	dirty = false
	
	for c in get_children():
		c.queue_free()

	for x in range(depth):
		var points = nodes.filter(func(p): return p.x == x)

		for i in range(points.size()):
			var n = points[i]
			var node = point_scene.instantiate() as Control
			var connections = edges.filter(func(e): return e.b == n)
			
			node.position = Vector2((n.x - depth/2.0 + 0.5) * x_diff, node_height_dist * n.y + y_offset) - node.size / 2
			node.gui_input.connect(func(ev: InputEvent):
				if ev.is_action_pressed("main_action"):
					var last_path = path[path.size() - 1] if not path.is_empty() else null
					var sources = connections.filter(func(e): return e.a == last_path)
					if last_path == n:
						if path.is_empty():
							for c in get_children():
								c.undim()
						
						path.erase(n)
						node.unmark()
						marked.emit()
					elif not sources.is_empty() or (last_path == null and n.x == 0):
						if path.is_empty():
							for c in get_children():
								c.dim()
						
						path.append(n)
						node.mark()
						marked.emit()
					queue_redraw()
			)
			add_child(node)

func has_finished_marking():
	return not path.filter(func(x): return x.x == depth - 1).is_empty()

func generate_nodes():
	nodes = []
	for i in range(depth):
		# var height = randi_range(max(1, prev_height - 1), min(prev_height + 1, max_height))
		var height = min(i, max_height - 1)
		if i == 0:
			height = 0

		var half_height = height / 2.0
		for j in range(height + 1):
			nodes.append(Vector2(i, half_height - j))

func connect_nodes():
	edges = []

	for n in nodes:
		var next = nodes.filter(func(p): return p.x == n.x + 1 and abs(p.y - n.y) < 1)
		for other in next:
			if n != other:
				edges.append({a = n, b = other, terrain = random_terrain()})

func add_extra_edges():
	var possible_edges = []
	for n in nodes:
		var next = nodes.filter(func(p): return p.x == n.x + 1 and abs(p.y - n.y) == 1)
		for other in next:
			if n != other and not edge_exists(n, other):
				possible_edges.append({a = n, b = other})
	
	for _i in range(min(extra_edges, possible_edges.size())):
		var edge = possible_edges.pick_random()
		edges.append({a = edge.a, b = edge.b, terrain = random_terrain()})
		possible_edges.erase(edge)
	
func edge_exists(a: Vector2, b: Vector2) -> bool:
	for edge in edges:
		if (edge.a == a and edge.b == b) or (edge.a == b and edge.b == a):
			return true
	return false

func random_terrain():
	return Terrain.values().pick_random()
