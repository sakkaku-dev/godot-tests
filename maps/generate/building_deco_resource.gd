class_name BuildingDecoResource
extends Resource

enum Align {
	START,
	CENTER,
	END,
}

@export var scene: PackedScene
@export var height := Vector2(0, 0)

@export var dirs: Array[Vector2] = []
@export var align := Align.START
