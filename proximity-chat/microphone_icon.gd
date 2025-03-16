class_name MicrophoneIcon
extends Control

@export var microphone: MicrophoneAudio
@export var fade_timer: Timer

@export var icon_texture: TextureButton 

func _ready() -> void:
	microphone.microphone_toggled.connect(update_icon)
	microphone.microphone_capturing.connect(fade_in)
	fade_timer.timeout.connect(fade_out)
	
	fade_out()

func fade_in():
	if not icon_texture.is_visible():
		icon_texture.show()

	fade_timer.start()

func fade_out():
	icon_texture.hide()

func update_icon(mute: bool):
	icon_texture.button_pressed = mute
	fade_in()
