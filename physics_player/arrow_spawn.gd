class_name ArrowSpawn
extends Marker3D

@export var arrow_scene: PackedScene
@onready var spawner := get_tree().get_first_node_in_group("spawner")

func spawn():
	var node = arrow_scene.instantiate()
	node.rotation = global_rotation
	node.position = global_position
	spawner.add_child(node)
