class_name Respawner
extends Area3D

func _ready() -> void:
	body_entered.connect(func(body): _respawn_at_checkpoint(body))

func _respawn_at_checkpoint(player: CharacterBody3D):
	if not player: return

	var checkpoint = _find_first_active_checkpoint()
	if checkpoint:
		player.global_transform.origin = checkpoint.global_transform.origin + Vector3.UP
		player.velocity = Vector3.ZERO


func _find_first_active_checkpoint():
	var checkpoints = get_tree().get_nodes_in_group(Checkpoint.GROUP)
	for checkpoint in checkpoints:
		if checkpoint.is_active:
			return checkpoint

	return null
