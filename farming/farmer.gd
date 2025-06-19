class_name Farmer
extends CharacterBody2D

@export var speed: float = 100.0
@export var placeholder: Placeholder
@export var toolbar: Toolbar

@export var initial_items: Array[ItemResource] = []

@onready var player_input: PlayerInput = $PlayerInput
@onready var pickup_area: Area2D = $PickupArea
@onready var inventory: Inventory = $Inventory

var is_placing: ItemResource = null:
	set(v):
		if is_placing == v:
			is_placing = null
		else:
			is_placing = v
			
		placeholder.type = is_placing.type if is_placing else null
		toolbar.update_active(is_placing)

func _ready() -> void:
	toolbar.pressed_item.connect(func(item): is_placing = item)
	pickup_area.area_entered.connect(func(area):
		if area is DropItem:
			if inventory.add_item(area.item):
				area.queue_free()
	)
	
	for i in initial_items:
		inventory.add_item(i)
	
func _physics_process(delta: float) -> void:
	var direction = player_input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if is_placing:
		if event.is_action_pressed("ui_cancel"):
			is_placing = null
		elif event.is_action_pressed("action"):
			if placeholder.do_action() and not is_placing.tool:
				var slot = inventory.get_slot_for_item(is_placing)
				inventory.remove_item(slot)
		elif event.is_action_pressed("secondary"):
			placeholder.do_secondary()
		get_viewport().set_input_as_handled()
