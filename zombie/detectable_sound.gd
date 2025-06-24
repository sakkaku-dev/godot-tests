class_name DetectableSound
extends Area3D

@export var throttle := 0.1
@export var base_volume := 1.0
@export var sound_falloff := 0.05

var last_played := 0.0

func play_sound():
	var seconds = Time.get_ticks_msec() / 1000.0
	if last_played + throttle > seconds:
		return  # Throttle the sound playback
	
	last_played = seconds
	for area in get_overlapping_areas():
		if area is HearingSound:
			var volume = base_volume * (1.0 - sound_falloff * global_position.distance_to(area.global_position))
			area.detected_sound(volume, global_position)
