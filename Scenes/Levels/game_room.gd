extends Node3D

@onready var player_spawn: Node3D = $PlayerSpawn

const PLAYER_SCENE: PackedScene = preload("uid://bs72ogkvdd7d6")

var player_index: int = 1
var total_players: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	total_players = multiplayer.get_peers().size() + 1 # +1 da nur Clients aufgezählt werden
	
	if not OS.has_feature("dedicated_server"): # Host muss bei Dedicated Server nicht hinzugefügt werden
		_add_player(1, player_index)
		player_index += 1
	
	for id in multiplayer.get_peers():
		_add_player(id, player_index)
		player_index += 1

func _exit_tree() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(_add_player)
	multiplayer.peer_disconnected.disconnect(_remove_player)

func _add_player(id: int, index: int):
	var player: Player = PLAYER_SCENE.instantiate()
	player.name = str(id)
	player_spawn.add_child(player, true)
	await get_tree().process_frame
	rpc("_spawn_player", player, index)

@rpc("authority", "call_local")
func _spawn_player(player, index: int):
	if not multiplayer.is_server():
		return
	player.global_position = get_spawn_position(index, total_players)
	player.set_look_at(Vector3.ZERO)
	player.can_jump = false
	player.can_move = false

func _remove_player(id: int):
	if not player_spawn.has_node(str(id)):
		return
	
	player_spawn.get_node(str(id)).queue_free()

func get_spawn_position(index: int, total_players_num: int, radius: float = 10.0) -> Vector3:
	var angle = (2 * PI / total_players_num) * index
	
	var x = cos(angle) * radius
	var z = sin(angle) * radius
	
	print("Index: ", index, ", Total Players: ", total_players_num, ", Angle: ", angle, ", X: ", x, ", Z: ", z)
	
	return Vector3(x, 0, z)
