extends Node

@onready var main_menu: Control = $MainMenu
@onready var level_spawn: Node = $LevelSpawn

const LOBBY_SCENE: PackedScene = preload("uid://c1bmx4oubegm4")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree().paused = true
	main_menu.hidden.connect(start_lobby)

func start_lobby():
	#get_tree().paused = false
	
	if multiplayer.is_server():
		change_to_level.call_deferred(LOBBY_SCENE)

func change_to_level(scene: PackedScene):
	for c in level_spawn.get_children():
		level_spawn.remove_child(c)
		c.queue_free()
	
	level_spawn.add_child(scene.instantiate())
