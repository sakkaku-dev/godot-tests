@tool
class_name ExpeditionMap
extends Control

signal marked()
signal picked_money(money: int)

@export var run := false:
	set(v):
		generate_map()

@export var node_height_dist = 50.0
@export var node_radius = 5.0
@export var depth = 4
@export var max_height = 2
@export var extra_edges = 3

@export var point_scene: PackedScene

@export_category("Money")
@export var money_chance = 0.3
@export var min_money = 4
@export var max_money = 8

enum Terrain {
	PLAINS,
	JUNGLE,
	MOUNTAIN,
	RIVER,
}

var inflation := 1.0
var terrains = [Terrain.PLAINS, Terrain.RIVER]
var dirty := false
var nodes = []
var edges = []
var node_terrains = {}
var node_money = {}

var current_pos := -1:
	set(v):
		current_pos = v
		if current_pos >= 0 and current_pos < path.size():
			var n = path[current_pos]
			for c in get_children():
				c.set_player(n)

var path := []

func generate_map():
	dirty = true
	path = []

	generate_nodes()
	connect_nodes()
	add_extra_edges()
	queue_redraw()

func increase_terrain():
	if not Terrain.MOUNTAIN in terrains:
		terrains.append(Terrain.MOUNTAIN)
	elif not Terrain.JUNGLE in terrains:
		terrains.append(Terrain.JUNGLE)
	elif Terrain.MOUNTAIN in terrains and Terrain.JUNGLE in terrains:
		terrains.append(Terrain.MOUNTAIN)
		terrains.append(Terrain.JUNGLE)

func has_reached_end():
	return current_pos >= 0 and current_pos == path.size() - 1

func _draw() -> void:
	var y_offset = size.y/10
	var x_diff = size.x / depth
	var y_center = size.y / 2 + y_offset

	for edge in edges:
		var a = edge.a
		var b = edge.b
		var p1 = Vector2((a.x + 0.5) * x_diff, y_center + node_height_dist * a.y)
		var p2 = Vector2((b.x + 0.5) * x_diff, y_center + node_height_dist * b.y)
		var color = Color.INDIAN_RED if a in path and b in path else Color.DIM_GRAY
		draw_line(p1, p2, color, 2)

	if not dirty: return
	dirty = false
	
	for c in get_children():
		c.queue_free()

	for x in range(depth):
		var points = nodes.filter(func(p): return p.x == x)

		for i in range(points.size()):
			var n = points[i]
			var node = point_scene.instantiate() as MapPoint
			var connections = edges.filter(func(e): return e.b == n)
			
			node.point = n
			node.terrain_type = node_terrains[n]
			node.money_amount = node_money.get(n, 0)
			node.position = Vector2((n.x - depth/2.0 + 0.5) * x_diff, node_height_dist * n.y + y_offset) - node.size / 2
			node.gui_input.connect(func(ev: InputEvent):
				if ev.is_action_pressed("main_action"):
					var last_path = path[path.size() - 1] if not path.is_empty() else null
					var sources = connections.filter(func(e): return e.a == last_path)
					if last_path == n:
						path.erase(n)
						node.unmark()

						if path.is_empty():
							for c in get_children():
								c.undim()
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

func start_game():
	for c in get_children():
		c.start()
	
	current_pos = 0
	queue_redraw()

func step_next():
	current_pos += 1
	var curr = get_current_point()
	var money = curr.take_money()
	if money > 0:
		picked_money.emit(money)

func stop_game():
	current_pos = -1
	path.clear()
	for c in get_children():
		c.stop()
	queue_redraw()

func has_finished_marking():
	return not path.filter(func(x): return x.x == depth - 1).is_empty()

func get_current_terrain():
	if current_pos >= 0 and current_pos < path.size():
		return node_terrains[path[current_pos]]
	return null

func is_game_running():
	return current_pos >= 0

func get_current_point():
	for c in get_children():
		if c.point == path[current_pos]:
			return c

func generate_nodes():
	nodes = []
	for i in range(depth):
		# var height = randi_range(max(1, prev_height - 1), min(prev_height + 1, max_height))
		var height = min(i, max_height - 1)
		if i == 0:
			height = 0

		var half_height = height / 2.0
		for j in range(height + 1):
			var p = Vector2(i, half_height - j)
			nodes.append(p)
			
			var is_first = i == 0
			node_terrains[p] = random_terrain() if not is_first else null

			if randf() < money_chance and not is_first:
				node_money[p] = int(randi_range(min_money, max_money) * inflation) * 10

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
	return terrains.pick_random()
