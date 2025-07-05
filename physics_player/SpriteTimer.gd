class_name SpriteTimer
extends Sprite3D

@export var timer: Timer

func _process(delta: float):
	if timer == null or timer.is_stopped():
		visible = false
		return
	
	visible = true
	var mat = material_override as ShaderMaterial
	var fill = timer.time_left / timer.wait_time
	mat.set_shader_parameter("fill", fill)
