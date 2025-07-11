class_name Placement
extends Node3D

@export var player: Node3D
@onready var dungeon_map: DungeonMap = get_tree().get_first_node_in_group(DungeonMap.GROUP)

var item:
    set(v):
        item = v
        visible = v != null

func _process(_delta: float) -> void:
    if item:
        var next_coord = get_placement_coord()
        global_position = dungeon_map.map_to_local(next_coord)

func get_placement_coord():
    var p_coord = get_player_coord()
    var forward_dir = get_player_forward_dir()
    return p_coord + forward_dir

func get_player_coord():
    return dungeon_map.local_to_map(player.global_position)

func get_player_forward_dir():
    var forward = player.global_transform.basis.z
    forward.y = 0
    return forward.normalized()

func pickup_item(pos: Vector3):
    var coord = dungeon_map.local_to_map(pos)
    if not dungeon_map.has_item(coord):
        print("No item at position", pos)
        return null
    
    item = dungeon_map.remove_item(coord)

func place_item():
    if not item:
        print("No item to place")
        return
    
    var coord = get_placement_coord()
    dungeon_map.place_item(coord, item)
    item = null

func has_item():
    return item != null