class_name WeatherLine
extends Control

const HOT = preload("res://assets/Free Paper UI System/1 Sprites/Day & Night Cycle/Items Holder/1/3 Noon/1.png")
const SUNNY = preload("res://assets/Free Paper UI System/1 Sprites/Day & Night Cycle/Items Holder/1/2 Day/1.png")
const THUNDER = preload("res://assets/Free Paper UI System/1 Sprites/Day & Night Cycle/Items Holder/1/5 Lightning 1/7.png")
const RAIN = preload("res://assets/Free Paper UI System/1 Sprites/Day & Night Cycle/Items Holder/1/7 Raining/1.png")

const DESC = {
	Expedition.Weather.SCORCHING: "You will need more water",
	Expedition.Weather.SUNNY: "A pleasant day for a walk",
	Expedition.Weather.RAIN: "You might catch a cold",
	Expedition.Weather.THUNDER: "You might get hit by lightning",
}

@export var weather_label: Label
@export var desc_label: Label
@export var weather_icon: TextureRect

var day = 0
var weather = Expedition.Weather.SCORCHING

func _ready() -> void:
	weather_label.text = "Day %s, %s" % [int(day), Expedition.Weather.keys()[weather]]
	desc_label.text = DESC[weather]
	
	match weather:
		Expedition.Weather.SCORCHING:
			weather_icon.texture = HOT
		Expedition.Weather.SUNNY:
			weather_icon.texture = SUNNY
		Expedition.Weather.RAIN:
			weather_icon.texture = RAIN
		Expedition.Weather.THUNDER:
			weather_icon.texture = THUNDER
