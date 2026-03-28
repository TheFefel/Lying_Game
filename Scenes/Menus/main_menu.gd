class_name MainMenu
extends Control

@onready var main_menu: Control = $"."
@onready var host_button: Button = $Buttons/HostButton
@onready var lobby_id_line: LineEdit = $Buttons/LobbyIDLine
@onready var join_button: Button = $Buttons/JoinButton
@onready var options_button: Button = $Buttons/OptionsButton
@onready var quit_button: Button = $Buttons/QuitButton

func _ready() -> void:
	SteamLobby.create_lobby_finished.connect(hide_main_menu)
	SteamLobby.join_lobby_finished.connect(hide_main_menu)

func _on_host_button_pressed() -> void:
	print("Host Button pressed")
	SteamLobby.create_lobby()

func _on_line_edit_text_changed(new_text: String) -> void:
	join_button.disabled = (new_text.length() == 0)

func _on_join_button_pressed() -> void:
	print("Join Button pressed")
	SteamLobby.join_lobby(lobby_id_line.text.to_int())

func hide_main_menu():
	main_menu.hide()
