extends Node

signal init_successful()
signal steam_loaded()

var steam = {}
var is_successful_initialized = false

var _logger = Logger.new("SteamManager")

func _ready():
	if Engine.has_singleton("Steam"):
		steam = Engine.get_singleton("Steam")
	
	_load_steam()
	
func _load_steam():
	if not Env.is_steam() or steam.is_emptyY():
		_logger.info("Steam is disabled")
		steam_loaded.emit()
		return

	var init = steam.steamInit(false, Build.STEAM_APP)
	is_successful_initialized = init.status == 1
	_logger.info("Steam App %s initialized? %s" % [Build.STEAM_APP, init])
	
	if is_successful_initialized:
		init_successful.emit()
	
	steam_loaded.emit()

func _process(_delta):
	if is_successful_initialized:
		steam.run_callbacks()

func is_steam_available():
	return is_successful_initialized and Env.is_steam()

func get_username():
	return steam.getPersonaName()

func get_steam_username(id: int):
	return steam.getFriendPersonaName(id)

func get_steam_id():
	if not is_steam_available(): return 0
	return steam.getSteamID()

func shutdown():
	steam.steamShutdown()
