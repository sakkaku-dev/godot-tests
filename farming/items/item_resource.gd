class_name ItemResource
extends Resource

enum Type {
	HOE,
	AXE,
	SEED,
	WATER,
}

@export var type := Type.HOE
@export var texture: Texture2D
@export var tool := true
@export var max_stack: int = 99
@export var count: int = 1

func can_merge_with(other: ItemResource) -> bool:
	return type == other.type and not tool and count + other.count <= max_stack

func merge(other: ItemResource) -> void:
	if can_merge_with(other):
		count += other.count

func is_stackable():
	return not tool
