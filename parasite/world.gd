extends TileMapLayer
class_name World

signal entity_moved(entity: GridEntity)
signal entity_attacked(entity: GridEntity)
signal all_hosts_acted  # New signal for turn management

@export var grid_size := Vector2i(8, 8)
@export var grid_tile_atlas_1 = Vector2i(34, 1)
@export var grid_tile_atlas_2 = Vector2i(32, 1)
@export var preview_layer: TileMapLayer

var entities := {}
var blocked_cells := {}
var selected_entity: GridEntity = null

func setup_grid():
	entities = {}
	blocked_cells = {}
	selected_entity = null

	for x in grid_size.x:
		for y in grid_size.y:
			var atlas = grid_tile_atlas_1 if (x + y) % 2 == 0 else grid_tile_atlas_2
			set_cell(Vector2i(x, y), 0, atlas)
	
	# Mark some cells as blocked (optional)
	# blocked_cells[Vector2i(3, 3)] = true

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return local_to_map(world_pos)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return map_to_local(grid_pos)

func is_cell_free(grid_pos: Vector2i) -> bool:
	return (
		is_inside_grid(grid_pos) &&
		!blocked_cells.has(grid_pos) &&
		!entities.has(grid_pos)
	)

func is_inside_grid(grid_pos: Vector2i) -> bool:
	return (
		grid_pos.x >= 0 && grid_pos.x < grid_size.x &&
		grid_pos.y >= 0 && grid_pos.y < grid_size.y
	)

# Register an entity to the grid
func add_entity(entity: Node2D, grid_pos: Vector2i) -> bool:
	if !is_cell_free(grid_pos):
		return false
	
	entities[grid_pos] = entity
	entity.position = grid_to_world(grid_pos)
	return true

# Move an entity on the grid
func move_entity(entity: Node2D, direction: Vector2i) -> bool:
	var current_pos : Vector2i = world_to_grid(entity.position)
	var target_pos := current_pos + direction
	
	if !is_cell_free(target_pos):
		return false  # Movement failed
	
	# Update grid tracking
	entities.erase(current_pos)
	entities[target_pos] = entity
	
	# Smooth movement (optional: tweak for turn-based)
	var tween = create_tween()
	tween.tween_property(entity, "position", grid_to_world(target_pos), 0.2)
	
	return true

# Remove an entity from the grid
func remove_entity(grid_pos: Vector2i):
	if entities.has(grid_pos):
		entities.erase(grid_pos)

# New methods for combat and selection
func get_entity_at(grid_pos: Vector2i) -> GridEntity:
	return entities.get(grid_pos)

func get_host_entities() -> Array:
	var hosts = []
	for entity in entities.values():
		if entity is GridEntity and entity.is_host:
			hosts.append(entity)
	return hosts

func get_ai_entities() -> Array:
	var ai_units = []
	for entity in entities.values():
		if entity is GridEntity and !entity.is_host:
			ai_units.append(entity)
	return ai_units

func is_attackable(grid_pos: Vector2i, attacker: GridEntity) -> bool:
	var target = get_entity_at(grid_pos)
	if !target: return false
	
	# Check if target is in attack pattern
	var relative_pos = grid_pos - world_to_grid(attacker.position)
	return relative_pos in attacker.current_attack_pattern

func has_parasitable_entity(grid_pos: Vector2i) -> bool:
	return entities.has(grid_pos) and !entities[grid_pos].is_host

func transfer_parasite(from_entity: GridEntity, to_entity: GridEntity):
	from_entity.is_host = false
	to_entity.is_host = true
	# Count parasite transfer as an attack action
	from_entity.on_attack_executed()

# Input handling for selection and movement
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = get_global_mouse_position()
		var grid_pos = world_to_grid(click_pos)
		
		# If we have a selected entity
		if selected_entity and selected_entity.is_selected:
			var current_pos = world_to_grid(selected_entity.position)
			
			# If clicking on the selected entity, cycle its state
			if grid_pos == current_pos:
				selected_entity.cycle_selection_state()
				return
			
			# Handle movement if in move state
			if selected_entity.current_selection_state == selected_entity.SelectionState.MOVE:
				var move_offset = grid_pos - current_pos
				if move_offset in selected_entity.current_move_pattern and is_cell_free(grid_pos):
					move_entity_to(selected_entity, grid_pos)
					selected_entity.deselect()
					selected_entity = null
					return
			
			# Handle attack if in attack state
			if selected_entity.current_selection_state == selected_entity.SelectionState.ATTACK:
				var attack_offset = grid_pos - current_pos
				if attack_offset in selected_entity.current_attack_pattern:
					if execute_attack(selected_entity, grid_pos):
						selected_entity.deselect()
						selected_entity = null
						return
			
			# Handle parasite transfer if in parasite state
			if selected_entity.current_selection_state == selected_entity.SelectionState.PARASITE:
				var transfer_offset = grid_pos - current_pos
				if transfer_offset in selected_entity.current_parasite_pattern:
					var target_entity = get_entity_at(grid_pos)
					if target_entity and !target_entity.is_host:
						transfer_parasite(selected_entity, target_entity)
						selected_entity.deselect()
						selected_entity = target_entity
						return
			
			# If clicking on another host entity, switch selection
			if entities.has(grid_pos):
				var clicked_entity = entities[grid_pos]
				if clicked_entity.is_host and clicked_entity != selected_entity:
					selected_entity.deselect()
					selected_entity = clicked_entity
					selected_entity.current_selection_state = clicked_entity.SelectionState.MOVE
					selected_entity.show_action_previews()
				# If clicking on non-host entity or same entity, just deselect
				else:
					selected_entity.deselect()
					selected_entity = null
			# If clicking elsewhere, just deselect
			else:
				selected_entity.deselect()
				selected_entity = null
		
		# If no entity is selected, try to select one
		elif entities.has(grid_pos):
			var clicked_entity = entities[grid_pos]
			if clicked_entity.is_host:  # Only select if it's a host
				if selected_entity:
					selected_entity.deselect()
				selected_entity = clicked_entity
				selected_entity.current_selection_state = clicked_entity.SelectionState.MOVE
				selected_entity.show_action_previews()

# Check if all host entities have completed their actions
func check_all_hosts_acted():
	for entity in entities.values():
		if entity.is_host and entity.can_take_actions():
			return  # At least one host can still act
	
	# If we get here, all hosts have acted
	emit_signal("all_hosts_acted")

# Reset all host entities for a new turn
func reset_host_actions():
	for entity in entities.values():
		if entity.is_host:
			entity.reset_actions()

# New method to move entity to a specific grid position
func move_entity_to(entity: Node2D, target_pos: Vector2i) -> bool:
	var current_pos = world_to_grid(entity.position)
	
	if !is_cell_free(target_pos):
		return false
	
	# Update grid tracking
	entities.erase(current_pos)
	entities[target_pos] = entity
	
	# Smooth movement
	var tween = create_tween()
	tween.tween_property(entity, "position", grid_to_world(target_pos), 0.2)
	
	# Update entity's action state
	if entity is GridEntity:
		entity.on_move_executed()
	
	# Emit signal for turn management
	emit_signal("entity_moved", entity)
	
	return true

# Check if there's a clear path to the target position
func has_clear_path(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	# If adjacent, always clear
	if (abs(from_pos.x - to_pos.x) <= 1 and abs(from_pos.y - to_pos.y) <= 1):
		return true
		
	# Get the direction vector
	var delta = to_pos - from_pos
	var steps = max(abs(delta.x), abs(delta.y))
	if steps == 0:
		return true
		
	# Normalize the direction
	var step: Vector2i = Vector2i(
		round(float(delta.x) / steps),
		round(float(delta.y) / steps)
	)
	
	# Check each step along the path
	var current := from_pos
	for i in range(1, steps):
		current += step
		if current != to_pos and entities.has(current):  # Allow targeting the final position
			return false
	
	return true

# Check if a position is valid for movement (clear path and free)
func is_valid_move_target(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	return is_inside_grid(to_pos) and has_clear_path(from_pos, to_pos)

# Check if a position is valid for attacking (clear path, can be empty)
func is_valid_attack_target(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	return is_inside_grid(to_pos) and has_clear_path(from_pos, to_pos)

# Handle attack execution
func execute_attack(attacker: GridEntity, target_pos: Vector2i) -> bool:
	var target = get_entity_at(target_pos)
	# Allow attacking empty fields, but only if it's a valid attack position
	var current_pos = world_to_grid(attacker.position)
	var attack_offset = target_pos - current_pos
	
	if !attack_offset in attacker.current_attack_pattern:
		return false
		
	if target:
		# Check counter mechanics
		match [attacker.unit_type, target.unit_type]:
			# Brute beats Sneak (armor too strong)
			["Brute", "Sneak"]:
				remove_entity_with_effect(target_pos)
			# Sneak beats Weaver (gets in close)
			["Sneak", "Weaver"]:
				remove_entity_with_effect(target_pos)
			# Weaver beats Brute (outranges)
			["Weaver", "Brute"]:
				remove_entity_with_effect(target_pos)
			_:
				# No effect for non-counter matchups
				print("Attack had no effect: ", attacker.unit_type, " vs ", target.unit_type)
	# else: Attack hits nothing, but still counts as using the attack
	
	# Update entity's action state
	attacker.on_attack_executed()
	
	# Emit signal for turn management
	emit_signal("entity_attacked", attacker)
	return true

# Remove entity with visual effect
func remove_entity_with_effect(grid_pos: Vector2i):
	var entity = get_entity_at(grid_pos)
	if entity:
		# TODO: Add visual effect here later
		print("Entity defeated: ", entity.unit_type)
		entity.queue_free()
		remove_entity(grid_pos)
