class_name HearingSound
extends Area3D

signal sound_heard(at: Vector3)

@export var volume_threshold: float = 0.8

func detected_sound(volume: float, at: Vector3) -> void:
	if volume > volume_threshold:
		sound_heard.emit(at)
		print("Sound detected by %s at volume %f" % [name, volume])
