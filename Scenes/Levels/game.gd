extends Node

@onready var main_menu: MainMenu = $MainMenu
@onready var level_loader: LevelLoader = $LevelLoader
@onready var player_spawner: PlayerSpawner = $PlayerSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu.hidden.connect(start_lobby)

func start_lobby():
	if multiplayer.is_server():
		await level_loader.spawn_level('lobby')
		player_spawner.spawn_player(1)
	else:
		await multiplayer.connected_to_server
	main_menu.queue_free()

func _on_start_game_pressed():
	if multiplayer.is_server():
		level_loader.spawn_level.rpc('game_room')
		player_spawner.position_players()
