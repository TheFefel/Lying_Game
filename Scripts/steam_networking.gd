extends Node

var app_id : int = 480
var lobby_id : int = 0
var peer : SteamMultiplayerPeer
var is_host : bool = false
var max_players : int = 8

@export var player_scene : PackedScene = preload("res://Addons/proto_controller/proto_controller.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_steam()
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)

func initialize_steam() -> void:
	var init_response: Dictionary = Steam.steamInitEx(app_id, true) #init Steam with app id and callbacks = true
	print("Did Steam initialize?: %s " % init_response)
	
	if init_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed to initialize Steam, shutting down: %s" % init_response)
		# Show some kind of prompt so the game doesn't suddently stop working
		get_tree().quit()

func host_lobby():
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY, max_players)
	is_host = true

func _on_lobby_created(result: int, lobby_id: int):
	if result == Steam.Result.RESULT_OK:
		self.lobby_id = lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player() #to add the host aswell

func _add_player(id: int = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _remove_player(id: int):
	if !self.has_node(str(id)):
		return
	
	self.get_node(str(id)).queue_free()


func _on_host_button_pressed():
	host_lobby()
