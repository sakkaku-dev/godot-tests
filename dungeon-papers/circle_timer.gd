# This somehow canne be used as a scene itself and needs to be copied to all places
# There is a problem with the reference to the SubViewport
class_name CircleTimer
extends Sprite3D

signal finished()

@export var color_rect: ColorRect
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(func(): finished.emit())

func start(time: float):
	timer.start(time)

func stop():
	timer.stop()

func is_working():
	return not timer.is_stopped()

func _process(_d: float) -> void:
	if timer.is_stopped():
		hide()
		return
	
	show()
	set_fill(timer.time_left / timer.wait_time)

func set_fill(v: float):
	var mat = color_rect.material as ShaderMaterial
	mat.set_shader_parameter("fill", v)
