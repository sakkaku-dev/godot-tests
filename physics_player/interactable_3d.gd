class_name Interactable3D
extends Area3D

@export var camera: Camera3D

signal interacted(hand: Hand3D)

var last_hand = null

func interact(hand: Hand3D):
	if last_hand: return

	last_hand = hand
	interacted.emit(hand)
	return camera

func release():
	if not last_hand: return

	last_hand.released.emit()
	last_hand = null
