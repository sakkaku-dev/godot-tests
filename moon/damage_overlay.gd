extends ColorRect

@export var oxygen: Oxygen

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	modulate = Color.TRANSPARENT
	oxygen.depleted.connect(func(): _show_overlay())
	oxygen.recovered.connect(func(): _hide_overlay())

func _show_overlay():
	print("Show overlay")
	animation_player.speed_scale = 1.0
	animation_player.play("oxygen")

func _hide_overlay():
	print("Hide overlay")
	animation_player.speed_scale = 3.0
	animation_player.play_backwards("oxygen")

#func _new_tween():
	#if tw and tw.is_running():
		#tw.kill()
	#
	#return create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
