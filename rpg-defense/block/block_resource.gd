class_name BlockResource
extends Resource

enum Type {
	BLOCK,
	FIRE,
	FROST,
	CRYSTAL,
}

@export var type := Type.BLOCK
@export var desc := ""
@export var scene: PackedScene
@export var health := 100
@export var cost := 10
