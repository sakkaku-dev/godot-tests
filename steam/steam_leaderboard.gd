extends Node

const DEMO_BOARD = "demo_mode"
const ENDLESS_BOARD = "endless_mode"
const STORY_BOARD = "story_mode"
const MULTIPLAYER_BOARD = "multiplayer_mode"

const DEFAULT_LEADERBOARDS = [
	ENDLESS_BOARD,
	STORY_BOARD,
	MULTIPLAYER_BOARD,
]
const DEMO_LEADERBOARDS = [
	DEMO_BOARD,
]

signal leaderboard_loaded(board: String, result: Array)
signal leaderboard_uploaded(board: String)
signal leaderboard_handler_loaded()

var leaderboard_handles: Dictionary = {}
var loading_handles := []
var last_result = []
var is_uploading := false
var handler_loaded := false
var score_range := 30

var _logger = Logger.new("SteamLeaderboard")

func _ready():
	SteamManager.init_successful.connect(func():
		SteamManager.steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
		SteamManager.steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
		SteamManager.steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
		_load_all_leaderboard()
	)

func _load_all_leaderboard():
	if Env.is_demo():
		loading_handles = DEMO_LEADERBOARDS.duplicate()
	else:
		loading_handles = DEFAULT_LEADERBOARDS.duplicate()
	
	_load_leaderboard_handle()

func _load_leaderboard_handle():
	if loading_handles.is_empty():
		handler_loaded = true
		_logger.info("Steam leaderboard handles loaded")
		leaderboard_handler_loaded.emit()
		return
	
	_logger.info("Loading steam leaderboard for %s" % [loading_handles[0]])
	SteamManager.steam.findLeaderboard(loading_handles[0])

func _on_leaderboard_find_result(handle: int, found: int) -> void:
	var board = loading_handles.pop_front()
	if found == 1 and board != null:
		leaderboard_handles[board] = handle
		_logger.info("Leaderboard %s found: %s" % [board, handle])
	else:
		_logger.warn("No handle was found for %s or loading handles empty: %s, %s, %s" % [board, loading_handles, handle, found])
	
	_load_leaderboard_handle()

func upload_score(board: String, score: int, details: String, keep_best = true):
	if not SteamManager.is_steam_available():
		_logger.warn("Steam not available to upload scores")
		return 

	if not board in leaderboard_handles:
		_logger.warn("Leaderboard %s hasn't been loaded" % board)
		return

	var detail_array = var_to_bytes(details).to_int32_array()
	SteamManager.steam.uploadLeaderboardScore(score, keep_best, detail_array, leaderboard_handles[board])
	_logger.info("Uploading score %s to %s with details of size %s" % [score, board, detail_array.size()])
	is_uploading = true

func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	var board = _find_leaderboard_for_handle(this_handle)
	is_uploading = false
	if success == 1:
		_logger.info("Successfully uploaded scores for %s!" % board)
		leaderboard_uploaded.emit(board)
	else:
		_logger.error("Failed to upload scores for %s!" % board)
		leaderboard_uploaded.emit(board)
	

func load_score(board: String, type: int):
	if not SteamManager.is_steam_available():
		_logger.warn("Steam is not available to load leaderboard scores")
		return []

	if not board in leaderboard_handles:
		_logger.warn("Leaderboard handle for %s not loaded" % board)
		return []

	if is_uploading:
		_logger.info("Awaiting score upload before fetching score for %s" % board)
		await leaderboard_uploaded
	
	if not handler_loaded:
		_logger.info("Awaiting leaderboard handles")
		await leaderboard_handler_loaded
	
	var start = 1
	var end = score_range
	if type == SteamManager.steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER:
		var mid = score_range/2.0
		start = ceil(-mid)
		end = floor(mid-1)
	
	_logger.info("Loading scores for %s using range %s - %s for board %s" % [type, start, end, board])
	SteamManager.steam.downloadLeaderboardEntries(start, end, type, leaderboard_handles[board])
	await leaderboard_loaded

	_logger.info("Loaded Leaderboard %s with %s entries" % [board, last_result.size()])
	return last_result

func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	_logger.debug("Scores downloaded message: %s" % message)
	
	var board = _find_leaderboard_for_handle(this_leaderboard_handle)
	if not board:
		_logger.warn("Leaderboard name not found for handle %s" % this_leaderboard_handle)
	
	last_result = result
	leaderboard_loaded.emit(board, result)

func _find_leaderboard_for_handle(handle: int):
	for k in leaderboard_handles.keys():
		if leaderboard_handles[k] == handle:
			return k
	return null
