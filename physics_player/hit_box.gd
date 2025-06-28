class_name HitBox
extends Area3D

@export var damage := 10

func do_hit():
	for box in get_overlapping_areas():
		if box is HurtBox:
			box.hurt(damage)
