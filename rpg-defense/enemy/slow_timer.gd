extends Timer

signal slowed()
signal restored()

@export var character: PhysicsCharacter

var slow_amount := 0.0:
	set(v):
		slow_amount = v
		character.speed_multiplier = max(1.0 - v, 0.0)

func _ready() -> void:
	timeout.connect(func(): slow_amount = 0.0)

func apply(amount: float, time: float):
	slow_amount = max(slow_amount, amount)
	start(time)
