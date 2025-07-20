class_name FastTapWork
extends StationWork

@export var spawn_scene: PackedScene
@export var spawn_chance := 0.2

func work():
	if randf() >= spawn_chance: return
	
	var node = spawn_scene.instantiate()
	node.position = global_position + Vector3.FORWARD.rotated(Vector3.UP, randf_range(-PI/2, PI/2)) * randf_range(0, 2)
	get_tree().current_scene.add_child(node)
