class_name HitBox
extends Area3D

@export var damage := 10
@export var knockback := 0.0

func do_hit():
	var has_hit := false
	for box in get_overlapping_areas():
		if box is HurtBox:
			box.hurt(damage)
			has_hit = true
			
			if knockback > 0:
				var dir = global_position.direction_to(box.global_position)
				dir.y = 0
				box.knockback(dir * knockback)
	return has_hit
