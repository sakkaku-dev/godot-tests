extends Camera2D

@export var world: World
@export var padding_ratio: float = 1.1  # 10% padding
@export var transition_speed: float = 5.0  # Zoom adjustment speed

var target_zoom: Vector2 = Vector2.ONE

func _ready():
	center_on_grid()
	adjust_zoom_to_fit_grid()

func _process(delta):
	if zoom != target_zoom:
		zoom = zoom.lerp(target_zoom, transition_speed * delta)

func center_on_grid():
	var grid_center_world = Vector2(
		world.grid_size.x * world.tile_set.tile_size.x / 2.0,
		world.grid_size.y * world.tile_set.tile_size.y / 2.0,
	)
	position = grid_center_world

func adjust_zoom_to_fit_grid():
	if !world || !get_viewport():
		return
	
	var viewport_size := get_viewport().get_visible_rect().size
	var grid_pixel_size := Vector2(
		world.grid_size.x * world.tile_set.tile_size.x,
		world.grid_size.y * world.tile_set.tile_size.y,
	)
	
	# Calculate the required zoom to fit grid in viewport
	var required_zoom := Vector2(
		viewport_size.x / (grid_pixel_size.x * padding_ratio),
		viewport_size.y / (grid_pixel_size.y * padding_ratio)
	)
	
	# Use the smaller zoom value to ensure everything fits
	target_zoom = Vector2(
		min(required_zoom.x, required_zoom.y),
		min(required_zoom.x, required_zoom.y)
	)
