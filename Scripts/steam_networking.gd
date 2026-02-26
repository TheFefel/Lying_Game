extends Node

var net_mode: String = "ENet" #Modus Steam oder ENet

var app_id: int = 480
var lobby_id: int = 0
var peer
var is_host: bool = false
var is_joining: bool = false
var max_players: int = 8

signal lobby_ready_to_join
signal joining_peer_created

#@onready var host_button: Button = $Buttons/HostLobbyButton
#@onready var join_button: Button = $Buttons/JoinLobbyButton
#@onready var id_prompt: LineEdit = $Buttons/EnterLobbyID
#@onready var lobby_scene: StringName = &"uid://x7kea0s7dgt5"


const player_scene: PackedScene = preload("uid://bs72ogkvdd7d6")

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
		lobby_ready_to_join.emit()
		print("Lobby ready to join")
	elif net_mode == "Steam":
		Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY, max_players)
		#is_host = true

func _on_lobby_created(result: int, _lobby_id: int):
	if result == Steam.Result.RESULT_OK:
		self.lobby_id = _lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player() #to add the host aswell
		
		print("Lobby created, lobby ID: ", _lobby_id)

func join_lobby(_lobby_id: int = 0):
	is_joining = true
	
	if net_mode == "ENet":
		peer.create_client("127.0.0.1", 1027)
	elif net_mode == "Steam":
		Steam.joinLobby(_lobby_id)
	
	multiplayer.multiplayer_peer = peer
	joining_peer_created.emit()
	print("Joining peer created")

func _on_lobby_joined(_lobby_id: int, permissions: int, locked: bool, response: int):
	if !is_joining:
		return
	
	self.lobby_id = _lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(_lobby_id))
	multiplayer.multiplayer_peer = peer
	
	is_joining = false

func _add_player(id: int = 1):
	await SceneLoader.load_finished
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _remove_player(id: int):
	if !self.has_node(str(id)):
		return
	
	self.get_node(str(id)).queue_free()
