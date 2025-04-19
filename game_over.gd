extends CanvasLayer

func _ready() -> void:
	if not $RestartButton.pressed.is_connected(_on_restart_pressed):
		$RestartButton.pressed.connect(_on_restart_pressed)
	get_tree().paused = true
	visible = true
	$AnimationPlayer.play("fade_in")
	if $GameOverSound.stream:
		print("GameOverSound stream loaded: ", $GameOverSound.stream.resource_path)
		$GameOverSound.play()
		print("GameOverSound playback started")
	else:
		push_error("GameOverSound stream is null or missing")
	print("Game over screen displayed")

func _on_restart_pressed() -> void:
	print("Restart button pressed")
	get_tree().paused = false
	if get_tree().change_scene_to_file("res://start_menu.tscn") != OK:
		push_error("Failed to load start menu")
	queue_free()
