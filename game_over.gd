extends CanvasLayer

func _ready() -> void:
	if not $RestartButton.pressed.is_connected(_on_restart_pressed):
		$RestartButton.pressed.connect(_on_restart_pressed)
	get_tree().paused = true
	visible = true
	print("Game over screen displayed")

func _on_restart_pressed() -> void:
	print("Restart button pressed")
	get_tree().paused = false
	if get_tree().reload_current_scene() != OK:
		push_error("Failed to reload scene")
	queue_free()
