extends Node

@onready var main_menu: Control = $MainMenu
@onready var level_spawn: Node = $LevelSpawn

const LOBBY_SCENE: PackedScene = preload("uid://c1bmx4oubegm4")
const LEVEL_SCENE: PackedScene = preload("uid://bu4n2e50i25wu")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu.hidden.connect(start_lobby)

func start_lobby():
	if multiplayer.is_server():
		change_to_lobby.call_deferred()

func change_to_level(scene: PackedScene):
	for c in level_spawn.get_children():
		level_spawn.remove_child(c)
		c.queue_free()
	
	level_spawn.add_child(scene.instantiate())

func change_to_lobby():
	for c in level_spawn.get_children():
		level_spawn.remove_child(c)
		c.queue_free()
	
	var lobby_instance = LOBBY_SCENE.instantiate()
	level_spawn.add_child(lobby_instance)
	
	lobby_instance.start_game_pressed.connect(_on_start_game_pressed)

func _on_start_game_pressed():
	change_to_level(LEVEL_SCENE)
	print("Changing to level scene")
