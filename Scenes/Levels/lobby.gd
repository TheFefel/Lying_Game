extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_tree_string_pretty())
	print(get_tree().current_scene)
	print($PlayerRoot)
