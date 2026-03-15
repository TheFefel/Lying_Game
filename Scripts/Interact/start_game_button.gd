extends Interactable

@export var level_spawn: Node

var level_scene = preload("uid://bu4n2e50i25wu")

func _on_interacted(body: Variant) -> void:
	if !multiplayer.is_server():
		print("The host has to start the game")
	else:
		start_game.rpc()

@rpc("authority", "call_local", "reliable")
func start_game():
	print("Starting game")
