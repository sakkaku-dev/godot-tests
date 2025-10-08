@tool
class_name PressureCell
extends Node3D

signal entered()
signal exited()

@onready var player_detector: Area3D = $PlayerDetector
@onready var pressure_cell: CSGBox3D = $PressureCell

func _ready() -> void:
	player_detector.body_entered.connect(func(_b): entered.emit())
	player_detector.body_exited.connect(func(_b): exited.emit())

	entered.connect(func(): pressure_cell.size.y = 0.05)
	exited.connect(func(): pressure_cell.size.y = 0.1)
