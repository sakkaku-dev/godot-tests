@tool
class_name Obstacle
extends Node3D

signal unlocked()
signal failed()

var seed := 0

func get_connection_points() -> Array:
	return []
