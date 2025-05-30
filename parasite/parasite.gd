extends Node
class_name GameManager

@export var world: World
@export var gameover_screen: Control

@export var entity_scenes: Dictionary = {
	"Brute": preload("res://parasite/grid_entity.tscn"),
	"Sneak": preload("res://parasite/grid_entity.tscn"),
	"Weaver": preload("res://parasite/grid_entity.tscn")
}

enum TurnState { PLAYER_TURN, AI_TURN }
var current_turn: TurnState = TurnState.PLAYER_TURN
var current_round: int = 0
var host_units: Array[String] = []  # Keeps track of unit types that are hosts

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
	current_round = 0
	host_units = ["Sneak"]  # Start with Sneak as the host
	start_round()

func start_round():
	world.setup_grid()
	spawn_round_entities()
	start_player_turn()
	print("Round ", current_round + 1, " started!")

func get_enemy_units_for_round() -> Array[String]:
	var enemies: Array[String] = []
	if current_round == 0:
		enemies.append("Weaver")
	elif current_round == 1:
		enemies.append("Brute")
	else:
		# First, add counters for each host unit
		for host_type in host_units:
			enemies.append(COUNTERED_BY[host_type])
		
		# Then add some additional enemies based on round number and host count
		var base_extra_enemies = 1  # Start with 1 extra enemy
		var host_power_factor = 1 + (host_units.size() * 0.5)  # More hosts = more enemies
		var round_factor = 0.5  # How much the round number affects enemy count
		
		var additional_enemies = roundi(base_extra_enemies * host_power_factor + (current_round - 2) * round_factor)
		
		# Add balanced mix of additional enemies
		for i in range(additional_enemies):
			var enemy_options = []
			
			# Check what types would be most threatening to current hosts
			for host_type in host_units:
				enemy_options.append(COUNTERED_BY[host_type])
				# Also add units that the host counters (for variety)
				enemy_options.append(COUNTERS[host_type])
			
			# Pick from the weighted options
			enemies.append(enemy_options[randi() % enemy_options.size()])
	
	print("Round ", current_round + 1, " enemies: ", enemies)
	return enemies

func spawn_round_entities():
	var bottom_row = world.grid_size.y - 2
	var spacing = world.grid_size.x / (host_units.size() + 1)
	
	print("Round ", current_round + 1, " starting with hosts: ", host_units)
	
	# Spawn host units at the bottom
	for i in range(host_units.size()):
		var spawn_pos = Vector2i(
			roundi((i + 1) * spacing),
			bottom_row
		)
		var entity = spawn_entity(host_units[i], spawn_pos)
		if entity:
			entity.is_host = true
	
	# Spawn enemy units with better spacing
	var enemy_units = get_enemy_units_for_round()
	var enemy_spacing = world.grid_size.x / (enemy_units.size() + 1)
	
	for i in range(enemy_units.size()):
		var base_pos = Vector2i(
			roundi((i + 1) * enemy_spacing),  # Spread enemies horizontally
			randi() % (world.grid_size.y - 4)  # Random height in top portion
		)
		
		var spawn_pos = find_safe_spawn_position(base_pos)
		spawn_entity(enemy_units[i], spawn_pos)

func find_safe_spawn_position(base_pos: Vector2i) -> Vector2i:
	var attempts = 0
	var current_pos = base_pos
	var max_attempts = 10
	
	while is_too_close_to_hosts(current_pos) and attempts < max_attempts:
		current_pos = Vector2i(
			base_pos.x + (randi() % 3 - 1),  # Small horizontal variation
			randi() % (world.grid_size.y - 4)  # New random height
		)
		attempts += 1
	
	return current_pos

func is_too_close_to_hosts(pos: Vector2i) -> bool:
	var min_distance = 3  # Minimum distance from hosts
	for entity in world.get_host_entities():
		var host_pos = world.world_to_grid(entity.position)
		if abs(pos.x - host_pos.x) + abs(pos.y - host_pos.y) < min_distance:
			return true
	return false

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
		# Round completed
		advance_round()

func advance_round():
	current_round += 1
	# Update host_units array with current hosts
	host_units.clear()
	for entity in world.get_host_entities():
		host_units.append(entity.unit_type)
	
	print("Round ", current_round, " completed! Hosts remaining: ", host_units)
	start_round()

func _on_all_hosts_acted():
	if current_turn == TurnState.PLAYER_TURN:
		start_ai_turn()

func spawn_initial_entities():
	# Spawn positions (adjust these as needed)
	var spawn_positions = {
		"Brute": Vector2i(2, world.grid_size.y - 2),  # Host player always at the bottom
		"Sneak": Vector2i(randi() % world.grid_size.x, randi() % (world.grid_size.y - 4)),
		"Weaver": Vector2i(randi() % world.grid_size.x, randi() % (world.grid_size.y - 4))
	}
	
	# Ensure AI entities are at least 2 tiles away from the host
	for unit_type in entity_scenes:
		if !spawn_positions.has(unit_type):
			push_warning("No spawn position defined for: ", unit_type)
			continue
		
		var spawn_pos = spawn_positions[unit_type]
		if unit_type != "Brute":
			while abs(spawn_pos.y - spawn_positions["Brute"].y) < 2:
				spawn_pos = Vector2i(randi() % world.grid_size.x, randi() % (world.grid_size.y - 4))
		
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
