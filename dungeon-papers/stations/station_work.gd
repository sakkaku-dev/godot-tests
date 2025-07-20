class_name StationWork
extends Node3D

signal finished()

func started_work():
	pass
func stopped_work():
	pass

func work():
	pass

func stop_work():
	pass

func item_placed(station: Station):
	pass

func item_removed():
	pass

func is_working() -> bool:
	return false
