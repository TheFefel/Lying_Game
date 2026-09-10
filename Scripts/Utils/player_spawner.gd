class_name PlayerSpawner
extends MultiplayerSpawner


const WARN_MSG := "Tried to remove a player that doesn't exist."


@onready var player_scene: PackedScene = preload("uid://bs72ogkvdd7d6")


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_connected(peer_id: int) -> void:
	if is_multiplayer_authority():
		spawn_player(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	if is_multiplayer_authority():
		remove_player(peer_id)


func spawn_player(id: int) -> void:
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	add_child.call_deferred(player)
	await player.tree_entered
	player.owner = self
	player.set_multiplayer_authority(id)


func remove_player(id: int) -> void:
	var player: Player = find_child(str(id))
	if player:
		player.queue_free()
	else:
		push_warning(WARN_MSG)


func clear_players() -> void:
	for child: Player in get_children():
		child.queue_free()

@rpc("authority", "call_local", "reliable")
func position_players() -> void:
	var index: int = 0
	var total_players: int = get_children().size()
	
	for player: Player in get_children():
		player.position = get_spawn_position(index, total_players)
		player.set_look_at(Vector3.ZERO)
		player.can_jump = false
		player.can_move = false
		index += 1

# Spawn function to let players spawn in a specific way based on the total players
# 2 players = spawn across from each other, 3 players = spawn in triangle and so on...
func get_spawn_position(index: int, total_players_num: int, radius: float = 10.0) -> Vector3:
	var angle = (2 * PI / total_players_num) * index
	
	var x = cos(angle) * radius
	var z = sin(angle) * radius
	
	print("Index: ", index, ", Total Players: ", total_players_num, ", Angle: ", angle, ", X: ", x, ", Z: ", z)
	
	return Vector3(x, 0, z)
