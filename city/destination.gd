class_name Destination
extends Node3D

@export var drop_area: Area3D
@onready var arrow_2: Node3D = $arrow2

func _ready():
	drop_area.body_entered.connect(func(pkg):
		if pkg is Package:
			pkg.start_drop(self)
	)
	drop_area.body_exited.connect(func(pkg):
		if pkg is Package:
			pkg.stop_drop()
	)
	
	unhighlight()

func highlight():
	arrow_2.show()

func unhighlight():
	arrow_2.hide()
