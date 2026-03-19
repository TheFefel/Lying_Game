extends Node3D
class_name LobbyScene

signal start_game_pressed

@onready var player_spawn: Node3D = $PlayerSpawn

const PLAYER_SCENE: PackedScene = preload("uid://bs72ogkvdd7d6")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	
	for id in multiplayer.get_peers():
		_add_player(id)
	
	if not OS.has_feature("dedicated_server"):
		_add_player(1)

func _exit_tree() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(_add_player)
	multiplayer.peer_disconnected.disconnect(_remove_player)

func _add_player(id: int):
	var player: Player = PLAYER_SCENE.instantiate()
	player.name = str(id)
	player.can_move = true
	player.can_jump = true
	player_spawn.add_child(player, true)

func _remove_player(id: int):
	if not player_spawn.has_node(str(id)):
		return
	
	player_spawn.get_node(str(id)).queue_free()


func _on_start_game_button_interacted(_body: Variant) -> void:
	if !multiplayer.is_server():
		print("The host has to start the game")
	else:
		start_game_pressed.emit()
		print("Emitted start_game_pressed")
