class_name Interactable
extends Area3D

signal interacted()

func interact():
	interacted.emit()
