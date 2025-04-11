class_name PlacementRayCast
extends RayCast3D

signal placed(item, pos: Vector3)

@export var rotate_amount_degrees := 5.0
@onready var rotate_amount = deg_to_rad(rotate_amount_degrees)

const PLACEMENT = preload("res://moon/placement.tres")

var obj = null
var node: Node3D
var is_valid := false

#var node_rotation = 0.0

func show_placement(object):
	if has_placement_object():
		cancel_placement()

	obj = object
	node = CSGCylinder3D.new()
	node.height = 0.3
	node.material = PLACEMENT
	get_tree().current_scene.add_child(node)

func place_object():
	if not has_placement_object() or not is_valid:
		return

	placed.emit(obj, node.global_position)
	obj = null
	node = null
	#node.place_object()

#func rotate_placement(delta):
	#if not has_placement_object():
		#return
	#
	#node_rotation += delta * rotate_amount

func _process(_delta: float) -> void:
	if not has_placement_object():
		return

	if is_colliding():
		var pos = get_collision_point()
		node.global_position = pos

		var normal = get_collision_normal()
		if normal:
			var rotation_basis = Vector3.UP.cross(normal)
			var dot = Vector3.UP.dot(normal)
			if rotation_basis.length() <= 0.5:
				rotation_basis = Vector3.RIGHT.cross(normal)
				
			var angle_between = acos(dot)
			#node.rotation = Quaternion(rotation_basis, angle_between).get_euler()
			is_valid = true
			node.show()

			#node.rotate(normal, node_rotation)
			return
	
	node.global_position = global_position + Vector3.FORWARD * 3
	node.hide()
	is_valid = false

	#node.rotate(Vector3.UP, node_rotation)

func has_placement_object():
	return obj and is_instance_valid(node) and node.is_inside_tree()

func cancel_placement():
	if not has_placement_object():
		return

	node.queue_free()
	obj = null
	node = null
