class_name Inventory
extends Node

@export var max_size := 20

var items = {}

func add_item(item: String, group = ""):
    if not group in items:
        items[group] = []

    items[group].append(item)

func remove_item(item: String, group = ""):
    if group in items and item in items[group]:
        items[group].erase(item)
        return true
    return false