class_name MapPoint
extends Control

@onready var highlight: TextureRect = $Highlight
@onready var mark_tex: TextureRect = $Mark
@onready var player: TextureRect = $Player
@onready var terrain: Label = $Terrain
@onready var money: TextureRect = $Money
@onready var circle: TextureRect = $Circle

const TERRAIN_COLOR = {
	ExpeditionMap.Terrain.PLAINS: Color(0.7, 1, 0.7),
	ExpeditionMap.Terrain.JUNGLE: Color(0.2, 0.8, 0.2),
	ExpeditionMap.Terrain.MOUNTAIN: Color(0.7, 0.7, 0.7),
	ExpeditionMap.Terrain.RIVER: Color(0.2, 0.4, 1),
}

var money_amount := 0
var terrain_type = null
var point: Vector2
var started := false

func _ready() -> void:
	highlight.hide()
	mark_tex.hide()
	player.hide()
	
	if terrain_type != null:
		terrain.text = "%s" % ExpeditionMap.Terrain.keys()[terrain_type]
		circle.modulate = TERRAIN_COLOR[terrain_type]
	else:
		terrain.hide()
	
	money.visible = money_amount > 0
	
	mouse_entered.connect(func():
		if not started:
			highlight.show()
	)
	mouse_exited.connect(func(): highlight.hide())

func mark():
	mark_tex.show()
	undim()

func unmark():
	mark_tex.hide()
	dim()

func dim():
	modulate = Color.LIGHT_GRAY

func undim():
	modulate = Color.WHITE

func start():
	started = true
	undim()
	unmark()

func stop():
	started = false
	player.hide()

func set_player(p: Vector2):
	player.visible = p == point

func take_money():
	var v = money_amount
	money_amount = 0
	money.hide()
	return v
