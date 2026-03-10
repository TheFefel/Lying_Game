extends Node

const APP_ID: int = 480

var steam_id
var is_online: bool
var is_game_owned: bool

func is_steam_enabled():
	return OS.has_feature("steam") or OS.is_debug_build()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_steam()
	steam_id = Steam.getSteamID()
	is_online = Steam.loggedOn()
	is_game_owned = Steam.isSubscribed()
	
	if is_game_owned == false:
		print("User does not own this game")
		get_tree().quit()

func initialize_steam() -> void:
	var init_response: Dictionary = Steam.steamInitEx(APP_ID, true)
	print("Did Steam initialize?: %s" % init_response)
	
	if init_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed to initialize Steam, shutting down: %s" % init_response)
		get_tree().quit()

func get_profile_name():
	return Steam.getPersonaName()
