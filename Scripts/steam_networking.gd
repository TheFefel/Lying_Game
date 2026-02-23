extends Node

@export_enum("Steam", "ENet") var net_mode: String = "Steam"

var app_id : int = 480
var lobby_id : int = 0
var peer
var is_host : bool = false
var is_joining : bool = false
var max_players : int = 8

@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
@onready var id_prompt: LineEdit = $IdPrompt


const player_scene : PackedScene = preload("uid://bs72ogkvdd7d6")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if net_mode == "ENet":
		peer = ENetMultiplayerPeer.new()
	elif net_mode == "Steam":
		peer = SteamMultiplayerPeer.new()
		initialize_steam()
		Steam.initRelayNetworkAccess()
		Steam.lobby_created.connect(_on_lobby_created)
		Steam.lobby_joined.connect(_on_lobby_joined)

func initialize_steam() -> void:
	var init_response: Dictionary = Steam.steamInitEx(app_id, true) #init Steam with app id and callbacks = true
	print("Did Steam initialize?: %s " % init_response)
	
	if init_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed to initialize Steam, shutting down: %s" % init_response)
		# Show some kind of prompt so the game doesn't suddently stop working
		get_tree().quit()

func host_lobby():
	if net_mode == "ENet":
		peer.create_server(1027)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player()
	elif net_mode == "Steam":
		Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY, max_players)
		#is_host = true

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
		
		print("Lobby created, lobby ID: ", lobby_id)

func join_lobby(lobby_id: int = 0):
	is_joining = true
	
	if net_mode == "ENet":
		peer.create_client("127.0.0.1", 1027)
	elif net_mode == "Steam":
		Steam.joinLobby(lobby_id)
	
	multiplayer.multiplayer_peer = peer

func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int):
	
	if !is_joining:
		return
	
	self.lobby_id = lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer
	
	is_joining = false

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


func _on_id_prompt_text_changed(new_text: String) -> void:
	join_button.disabled = (new_text.to_int() == 0)


func _on_join_button_pressed() -> void:
	join_lobby(id_prompt.text.to_int())
