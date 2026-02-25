extends CanvasLayer

signal loading_screen_ready

@export var animation_player: AnimationPlayer
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()

func _on_progress_changed(progress_value: float) -> void:
	var percentage = progress_value * 100
	progress_bar.value = percentage

func _on_load_finished() -> void:
	remove_child(progress_bar)
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()
