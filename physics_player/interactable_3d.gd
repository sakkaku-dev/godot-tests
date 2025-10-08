class_name Interactable3D
extends Area3D

signal interacted(hand: Hand3D)
signal released(hand: Hand3D)

var last_hand = null

func interact(hand: Hand3D) -> void:
	if last_hand: return

	last_hand = hand
	interacted.emit(hand)

func release(hand: Hand3D) -> void:
	if hand != last_hand: return

	last_hand = null
	released.emit(hand)
