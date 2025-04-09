class_name Interactable
extends Area3D

signal interacted()

func interact(actor):
	interacted.emit(actor)
