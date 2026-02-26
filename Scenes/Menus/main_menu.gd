extends Control

@onready var host_button: Button = $Buttons/HostLobbyButton
@onready var join_button: Button = $Buttons/JoinLobbyButton
@onready var id_prompt: LineEdit = $Buttons/EnterLobbyID
@onready var lobby_scene: StringName = &"uid://x7kea0s7dgt5"

func _on_host_lobby_button_pressed() -> void:
	SteamNetworking.host_lobby()
	SceneLoader.load_scene(lobby_scene)


func _on_enter_lobby_id_text_changed(new_text: String) -> void:
	join_button.disabled = (new_text.to_int() == 0)


func _on_join_lobby_button_pressed() -> void:
	SteamNetworking.join_lobby(id_prompt.text.to_int())
	SceneLoader.load_scene(lobby_scene)
