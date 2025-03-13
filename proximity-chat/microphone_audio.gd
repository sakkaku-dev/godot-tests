extends AudioStreamPlayer

@export var record_bus := "Record"
@export var buffer_size := 512
@export var audio_player: AudioStreamPlayer3D

@onready var idx = AudioServer.get_bus_index(record_bus)
@onready var effect: AudioEffectCapture = AudioServer.get_bus_effect(idx, 0)
@onready var playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _ready() -> void:
	set_process_unhandled_input(is_multiplayer_authority())
	set_process(is_multiplayer_authority())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("push_to_talk"):
		play()
	elif event.is_action_released("push_to_talk"):
		stop()

func _process(delta: float) -> void:
	if not playing: return
	
	if effect.can_get_buffer(buffer_size) and playback.can_push_buffer(buffer_size):
		_send_audio_data.rpc(effect.get_buffer(buffer_size))
	effect.clear_buffer()

@rpc("any_peer", "call_remote", "reliable")
func _send_audio_data(data: PackedVector2Array):
	for i in range(0, buffer_size):
		playback.push_frame(data[i])
