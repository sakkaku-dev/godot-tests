class_name Farmer
extends CharacterBody2D

@export var speed: float = 100.0
@export var placeholder: Placeholder
@export var items_slots: Control

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
		
		for c in items_slots.get_children():
			c.active = c.item == is_placing and is_placing != null

func _ready() -> void:
	for c in items_slots.get_children():
		c.pressed.connect(func(): is_placing = c.item)
	
	pickup_area.area_entered.connect(func(area):
		if area is DropItem:
			if inventory.add_item(area.item):
				area.queue_free()
	)

func _physics_process(delta: float) -> void:
	var direction = player_input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if is_placing:
		if event.is_action_pressed("ui_cancel"):
			is_placing = null
		elif event.is_action_pressed("action"):
			placeholder.do_action()
		elif event.is_action_pressed("secondary"):
			placeholder.do_secondary()
		get_viewport().set_input_as_handled()
