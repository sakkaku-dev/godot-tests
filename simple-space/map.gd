@tool
extends Control

@export var run := false:
	set(v):
		generate_map()

@export var node_height_dist = 50.0
@export var node_radius = 5.0
@export var depth = 4
@export var max_height = 2
@export var extra_edges = 3

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

var nodes = []
var edges = []

func _ready() -> void:
	generate_map()

func generate_map():
	generate_nodes()
	connect_nodes()
	add_extra_edges()
	queue_redraw()

func _draw() -> void:
	var x_diff = size.x / depth
	var y_center = size.y / 2

	for edge in edges:
		var a = edge.a
		var b = edge.b
		var p1 = Vector2((a.x + 0.5) * x_diff, y_center + node_height_dist * a.y)
		var p2 = Vector2((b.x + 0.5) * x_diff, y_center + node_height_dist * b.y)
		draw_line(p1, p2, TERRAIN_COLOR[edge.terrain], 2)

	for x in range(depth):
		var points = nodes.filter(func(p): return p.x == x)

		for i in range(points.size()):
			var n = points[i]
			var p = Vector2((n.x + 0.5) * x_diff, y_center + node_height_dist * n.y)
			var tex = LOCATION_TEXTURE[Location.NONE] as Texture2D
			draw_texture(tex, p - tex.get_size() / 2.0)
	

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
