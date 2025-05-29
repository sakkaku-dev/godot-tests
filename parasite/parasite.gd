extends Node
class_name GameManager

@export var world: World
@export var entity_scenes: Dictionary = {
	"Brute": preload("res://parasite/grid_entity.tscn"),
	"Sneak": preload("res://parasite/grid_entity.tscn"),
	"Weaver": preload("res://parasite/grid_entity.tscn")
}

@export var gameover_screen: Control

enum TurnState { PLAYER_TURN, AI_TURN }
var current_turn: TurnState = TurnState.PLAYER_TURN

# Counter relationships
const COUNTERS = {
	"Brute": "Sneak",   # Brute beats Sneak
	"Sneak": "Weaver",  # Sneak beats Weaver
	"Weaver": "Brute"   # Weaver beats Brute
}

const COUNTERED_BY = {
	"Brute": "Weaver",  # Brute is beaten by Weaver
	"Sneak": "Brute",   # Sneak is beaten by Brute
	"Weaver": "Sneak"   # Weaver is beaten by Sneak
}

func _ready():
	world.all_hosts_acted.connect(_on_all_hosts_acted)
	world.entity_attacked.connect(_on_world_entity_attacked)
	
	# Wait for world to initialize
	await get_tree().process_frame
	start_game()

func start_game():
	gameover_screen.hide()
	world.setup_grid()
	spawn_initial_entities()
	start_player_turn()

func start_player_turn():
	current_turn = TurnState.PLAYER_TURN
	world.reset_host_actions()
	print("Player turn started")

func start_ai_turn():
	current_turn = TurnState.AI_TURN
	print("AI turn started")
	process_ai_turn()

func process_ai_turn():
	var ai_entities = world.get_ai_entities()
	for entity in ai_entities:
		await process_ai_entity(entity)
		await get_tree().create_timer(1.0).timeout  # Small delay before ending AI turn

	end_ai_turn()

func process_ai_entity(entity: GridEntity):
	var current_pos = world.world_to_grid(entity.position)
	var host_entities = world.get_host_entities()
	
	# Find nearest host entity
	var nearest_host = null
	var nearest_dist = 999999
	for host in host_entities:
		var host_pos = world.world_to_grid(host.position)
		var dist = abs(current_pos.x - host_pos.x) + abs(current_pos.y - host_pos.y)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_host = host
	
	if nearest_host:
		var host_pos = world.world_to_grid(nearest_host.position)
		
		# Determine if we counter the host or are countered by it
		var we_counter = COUNTERS[entity.unit_type] == nearest_host.unit_type
		var they_counter = COUNTERED_BY[entity.unit_type] == nearest_host.unit_type
		
		# Get best move based on relationship
		var move_pos = get_best_move_position(entity, current_pos, host_pos, we_counter, they_counter)
		
		if move_pos != current_pos:
			# Execute move
			await get_tree().create_timer(0.3).timeout  # Small delay for visual clarity
			world.move_entity_to(entity, move_pos)
		
		# After moving, check if we can attack
		var new_pos = world.world_to_grid(entity.position)
		if we_counter:
			# Try to attack if we counter them and they're in range
			var attack_positions = get_attack_positions(entity, new_pos)
			if host_pos in attack_positions:
				await get_tree().create_timer(0.3).timeout
				world.execute_attack(entity, host_pos)

func get_best_move_position(entity: GridEntity, current_pos: Vector2i, target_pos: Vector2i, we_counter: bool, they_counter: bool) -> Vector2i:
	var best_pos = current_pos
	var best_score = -999999
	
	# Get all possible move positions
	for offset in entity.current_move_pattern:
		var move_pos = current_pos + offset
		if !world.is_valid_move_target(current_pos, move_pos):
			continue
			
		var score = evaluate_position(move_pos, target_pos, we_counter, they_counter)
		if score > best_score:
			best_score = score
			best_pos = move_pos
	
	return best_pos

func evaluate_position(pos: Vector2i, target_pos: Vector2i, we_counter: bool, they_counter: bool) -> float:
	var distance = abs(pos.x - target_pos.x) + abs(pos.y - target_pos.y)
	
	if we_counter:
		# If we counter them, try to get close but stay at attack range
		if distance <= 2:
			return 100 - distance  # Prefer positions closer but not too close
		else:
			return 50 - distance  # Try to get closer if we're far
	elif they_counter:
		# If they counter us, try to stay away
		if distance < 3:
			return -100 + distance  # Strongly avoid close positions
		else:
			return 50 + distance  # Prefer positions further away
	else:
		# No counter relationship, maintain medium distance
		return 50 - abs(distance - 3)  # Try to stay at distance 3

func get_attack_positions(entity: GridEntity, current_pos: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for offset in entity.current_attack_pattern:
		var attack_pos = current_pos + offset
		if world.is_valid_attack_target(current_pos, attack_pos):
			positions.append(attack_pos)
	return positions

func end_ai_turn():
	start_player_turn()

func _on_world_entity_attacked(entity: GridEntity):
	if world.get_host_entities().is_empty():
		gameover_screen.show()
	elif world.get_ai_entities().is_empty():
		start_game()

func _on_all_hosts_acted():
	if current_turn == TurnState.PLAYER_TURN:
		start_ai_turn()

func spawn_initial_entities():
	# Spawn positions (adjust these as needed)
	var spawn_positions = {
		"Brute": Vector2i(2, 2),
		"Sneak": Vector2i(world.grid_size.x - 3, 2),
		"Weaver": Vector2i(world.grid_size.x / 2, world.grid_size.y - 3)
	}
	
	for unit_type in entity_scenes:
		if !spawn_positions.has(unit_type):
			push_warning("No spawn position defined for: ", unit_type)
			continue
		
		var spawn_pos = spawn_positions[unit_type]
		var entity = spawn_entity(unit_type, spawn_pos)

		# Make the Brute the initial host (or whichever you prefer)
		if unit_type == "Brute" and entity:
			set_host(entity)

func set_host(new_host: GridEntity):
	# Clear host status from all entities
	for entity in get_tree().get_nodes_in_group("entities"):
		entity.is_host = false
	
	# Set new host
	new_host.is_host = true
	print("New host set: ", new_host.unit_type)

func spawn_entity(unit_type: String, grid_pos: Vector2i) -> GridEntity:
	if !entity_scenes.has(unit_type):
		push_error("No scene defined for unit type: ", unit_type)
		return null
	
	if !world.is_cell_free(grid_pos):
		push_error("Cannot spawn ", unit_type, " at occupied position: ", grid_pos)
		return null
	
	var entity_instance = entity_scenes[unit_type].instantiate()
	entity_instance.unit_type = unit_type
	entity_instance.world = world
	add_child(entity_instance)
	
	if !world.add_entity(entity_instance, grid_pos):
		entity_instance.queue_free()
		return null
	
	print("Spawned ", unit_type, " at ", grid_pos)
	return entity_instance
