extends Node

var lobby_id : int = 0
var peer : SteamMultiplayerPeer
var is_host : bool = false
var max_players : int = 8

@export var player_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.initRelayNetworkAccess()

func host_lobby():
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY, max_players)
