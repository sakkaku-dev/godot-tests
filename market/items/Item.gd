class_name Item
extends Node3D

const PREVIEW_MAT = preload("res://market/items/preview_mat.tres")

@export var mesh: MeshInstance3D
@onready var interactable: Interactable = $Interactable
@onready var static_body: StaticBody3D = $StaticBody3D

func _ready() -> void:
	picked_up()
	interactable.interacted.connect(func(p: PhysicsPlayer):
		p.pickup(self)
		picked_up()
	)

func picked_up():
	mesh.material_override = PREVIEW_MAT
	_set_static_body(true)

func _set_static_body(disabled = false):
	for c in static_body.get_children():
		if c is CollisionShape3D:
			c.disabled = disabled

func place():
	mesh.material_override = null
	_set_static_body(false)

func self_rotate():
	rotate_y(PI/2)
