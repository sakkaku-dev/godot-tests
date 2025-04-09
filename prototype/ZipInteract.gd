extends Interactable

@export var path: Path3D
@export var progress := 0.0
@export var speed := 1.0

func interact(actor):
	if path.curve.point_count <= 0:
		return
	
	var follow = PathFollow3D.new()
	var remote = RemoteTransform3D.new()
	remote.update_rotation = false
	remote.update_scale = false
	
	follow.add_child(remote)
	path.add_child(follow)
	follow.progress_ratio = progress
	return follow
