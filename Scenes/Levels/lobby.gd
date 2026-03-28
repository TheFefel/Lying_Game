extends Node3D
class_name LobbyScene

signal start_game_pressed

func _on_start_game_button_interacted(_body: Variant) -> void:
	if !multiplayer.is_server():
		print("The host has to start the game")
	else:
		start_game_pressed.emit()
		print("Emitted start_game_pressed")
