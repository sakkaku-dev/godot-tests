class_name ItemResource
extends Resource

enum Type {
    WATER,
    FOOD,
    SWEETS,
    ARMOR,
    CLOTHES,
    BOOTS,
    GLOVES,
    HERBS,
}

@export var image: Texture2D
@export var type := Type.WATER
@export var description: String
@export var price: int