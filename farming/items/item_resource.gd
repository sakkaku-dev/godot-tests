class_name ItemResource
extends Resource

enum Type {
	HOE,
	AXE,
	SEED,
}

@export var type := Type.HOE
@export var texture: Texture2D
