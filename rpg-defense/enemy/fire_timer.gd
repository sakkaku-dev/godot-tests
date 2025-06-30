extends Node

@export var hurt_box: HurtBox

func apply(amount: float, time: float):
	hurt_box.hurt(amount)
