class_name MicrophoneAudio
extends AudioStreamPlayer

signal microphone_toggled(mute)
signal microphone_capturing()

@export var record_bus := "Record"
@export var audio_player: AudioStreamPlayer3D
@export_range(0.0, 1.0, 0.001) var input_threshold := 0.01
@export var listen_self := false

@onready var idx = AudioServer.get_bus_index(record_bus)
@onready var effect: AudioEffectCapture = AudioServer.get_bus_effect(idx, 0)
@onready var playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback

var received_buffer := PackedVector2Array()

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	set_process_unhandled_input(is_multiplayer_authority())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("push_to_talk"):
		play()
		microphone_toggled.emit(playing)
	elif event.is_action_released("push_to_talk"):
		stop()
		microphone_toggled.emit(playing)

func _process(_delta: float) -> void:
	_process_voice()
	_process_mic()

func _process_mic():
	if not is_multiplayer_authority(): return

	var stereo_data = effect.get_buffer(effect.get_frames_available())
	if stereo_data.is_empty(): return

	# var mono_data = PackedFloat32Array()
	# mono_data.resize(stereo_data.size())

	var max_value = 0.0
	for d in stereo_data:
		var value = (d.x + d.y) / 2.0
		max_value = max(max_value, value)
		# mono_data.append(value)
	
	if max_value < input_threshold: return

	if playing:
		if listen_self:
			_send_audio_data(stereo_data)
		else:
			_send_audio_data.rpc(stereo_data)

	microphone_capturing.emit()

@rpc("any_peer", "call_remote")
func _send_audio_data(data: PackedVector2Array):
	received_buffer.append_array(data)

func _process_voice():
	if not audio_player.playing: return
	if playback.get_frames_available() < 1: return
	
	for i in range(min(playback.get_frames_available(), received_buffer.size())):
		playback.push_frame(received_buffer[0])
		received_buffer.remove_at(0)
