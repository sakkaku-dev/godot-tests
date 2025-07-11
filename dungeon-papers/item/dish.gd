class_name Dish
extends Item

@export var components: Array[String] = []
@export var is_complete_dish: bool = true

func add_component(item_name: String):
	if not is_complete_dish:
		components.append(item_name)
		# Update texture/representation based on components
		update_appearance()

func update_appearance():
	# Implement logic to change appearance based on components
	pass
