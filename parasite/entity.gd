extends Node2D
class_name GridEntity

@export var world: World
@export var unit_type: String = "Brute"  # "Brute", "Sneak", or "Weaver"

@export var move_preview_atlas := Vector2(21, 0)
@export var attack_preview_atlas := Vector2(21, 12)
@export var parasite_preview_atlas := Vector2(5, 12)

# New host control property
@export var is_host: bool = false:
	set(value):
		is_host = value
		update_host_visuals()  # Update appearance when host status changes
		if value:  # Reset actions when becoming host
			has_moved = false
			has_attacked = false

var sprite: Sprite2D
var current_move_pattern: Array[Vector2i] = []
var current_attack_pattern: Array[Vector2i] = []
var current_parasite_pattern: Array[Vector2i] = []
var is_selected: bool = false

enum SelectionState { NONE, MOVE, ATTACK, PARASITE }
var current_selection_state: SelectionState = SelectionState.NONE

# Action tracking
var has_moved: bool = false
var has_attacked: bool = false

func _ready():
	update_movement_rules()
	current_parasite_pattern = get_square_pattern(2)
	if !world:
		push_error("Entity: No World assigned!")

# Update movement/attack patterns based on unit type
func update_movement_rules():
	for c in get_children():
		c.visible = false

	match unit_type:
		"Brute":
			# Slow but heavily armored - moves only 2 spaces in a cross pattern
			current_move_pattern = combine_patterns([get_orthogonal_pattern(1), get_diagonal_pattern(1)])
			# Strong melee attack in all adjacent tiles
			current_attack_pattern= combine_patterns([get_orthogonal_pattern(1), get_diagonal_pattern(1)])
			sprite = $Brute
		"Sneak":
			# Fast and agile - can move up to 4 spaces in any direction
			current_move_pattern = combine_patterns([get_orthogonal_pattern(3), get_diagonal_pattern(2)])
			# Quick but weak attacks in adjacent tiles
			current_attack_pattern = combine_patterns([get_orthogonal_pattern(1), get_diagonal_pattern(1)])
			sprite = $Sneak
		"Weaver":
			# Medium speed - moves up to 3 spaces orthogonally
			current_move_pattern = get_diagonal_pattern(2)
			# Strong ranged attack in a cross pattern up to 3 tiles away
			current_attack_pattern = get_orthogonal_pattern(4)
			sprite = $Weaver

	sprite.visible = true

func update_host_visuals():
	if !sprite:
		return
	
	if is_host:
		sprite.modulate = Color(1.2, 0.8, 0.8)  # Slight glow
	else:
		sprite.modulate = Color.WHITE

# Show preview when selected
func show_action_previews():
	clear_previews()
	if !is_host:  # Don't allow selection of non-host entities
		return
		
	# Don't show move preview if already moved
	if has_moved and current_selection_state == SelectionState.MOVE:
		cycle_selection_state()  # Skip to next state if can't move
		return
		
	# Don't show attack or parasite preview if already attacked
	if has_attacked and (current_selection_state == SelectionState.ATTACK or current_selection_state == SelectionState.PARASITE):
		cycle_selection_state()  # Skip to next state if can't attack
		return
	
	is_selected = true
	match current_selection_state:
		SelectionState.MOVE:
			if !has_moved:
				draw_movement_preview()
		SelectionState.ATTACK:
			if !has_attacked:
				draw_attack_preview()
		SelectionState.PARASITE:
			if !has_attacked:  # Only show parasite preview if haven't attacked
				draw_parasite_preview()

func cycle_selection_state():
	if !is_host:
		return
		
	match current_selection_state:
		SelectionState.NONE:
			current_selection_state = SelectionState.MOVE
			if has_moved:  # Skip move if already moved
				cycle_selection_state()
			else:
				show_action_previews()
		SelectionState.MOVE:
			current_selection_state = SelectionState.ATTACK
			if has_attacked:  # Skip attack if already attacked
				cycle_selection_state()
			else:
				show_action_previews()
		SelectionState.ATTACK:
			current_selection_state = SelectionState.PARASITE
			if has_attacked:  # Skip parasite if already attacked
				cycle_selection_state()
			else:
				show_action_previews()
		SelectionState.PARASITE:
			deselect()

func deselect():
	is_selected = false
	current_selection_state = SelectionState.NONE
	clear_previews()

func clear_previews():
	world.preview_layer.clear()

func draw_movement_preview():
	var current_pos = world.world_to_grid(position)
	for offset in current_move_pattern:
		var target_pos = current_pos + offset
		if world.is_valid_move_target(current_pos, target_pos):
			world.preview_layer.set_cell(target_pos, 0, move_preview_atlas)

func draw_attack_preview():
	var current_pos = world.world_to_grid(position)
	for offset in current_attack_pattern:
		var target_pos = current_pos + offset
		if world.is_valid_attack_target(current_pos, target_pos):
			world.preview_layer.set_cell(target_pos, 0, attack_preview_atlas)

func draw_parasite_preview():
	var current_pos = world.world_to_grid(position)
	for offset in current_parasite_pattern:
		var target_pos = current_pos + offset
		if world.is_inside_grid(target_pos) and world.has_clear_path(current_pos, target_pos):
			world.preview_layer.set_cell(target_pos, 0, parasite_preview_atlas)

# Movement pattern generators
func get_diagonal_pattern(range: int) -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []
	for x in range(-range, range + 1):
		for y in range(-range, range + 1):
			if abs(x) == abs(y):
				pattern.append(Vector2i(x, y))
	return pattern

func get_orthogonal_pattern(range: int) -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []
	for i in range(1, range + 1):
		pattern.append(Vector2i(0, i))
		pattern.append(Vector2i(i, 0))
		pattern.append(Vector2i(0, -i))
		pattern.append(Vector2i(-i, 0))
	return pattern

func get_square_pattern(range: int) -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []
	for x in range(-range, range + 1):
		for y in range(-range, range + 1):
			if Vector2i(x, y) != Vector2i.ZERO:
				pattern.append(Vector2i(x, y))
	return pattern

func combine_patterns(patterns: Array) -> Array[Vector2i]:
	var combined_pattern: Array[Vector2i] = []
	for pattern in patterns:
		combined_pattern.append_array(pattern)
	return combined_pattern

func reset_actions():
	has_moved = false
	has_attacked = false

func can_take_actions() -> bool:
	return is_host and (!has_moved or !has_attacked)

func on_move_executed():
	has_moved = true
	world.check_all_hosts_acted()

func on_attack_executed():
	has_attacked = true
	has_moved = true
	world.check_all_hosts_acted()
