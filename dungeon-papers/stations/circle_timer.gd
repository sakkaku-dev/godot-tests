# This somehow canne be used as a scene itself and needs to be copied to all places
# There is a problem with the reference to the SubViewport
class_name CircleTimer
extends StationWork

@onready var timer: Timer = $Timer
@onready var color_rect: ColorRect = $SubViewport/ColorRect

func _process(_d: float) -> void:
	if timer.is_stopped():
		hide()
		return
	
	show()
	set_fill(timer.time_left / timer.wait_time)

func set_fill(v: float):
	var mat = color_rect.material as ShaderMaterial
	mat.set_shader_parameter("fill", v)
