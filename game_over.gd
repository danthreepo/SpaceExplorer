extends CanvasLayer

# Initialize the game-over screen, pause game, play sound and animation
func _ready() -> void:
	if not $RestartButton.pressed.is_connected(_on_restart_pressed):
		$RestartButton.pressed.connect(_on_restart_pressed)
	get_tree().paused = true
	visible = true
	$AnimationPlayer.play("fade_in")
	if $GameOverSound.stream:
		print("GameOverSound stream loaded: ", $GameOverSound.stream.resource_path) # Debug
		$GameOverSound.play()
		print("GameOverSound playback started") # Debug
	else:
		push_error("GameOverSound stream is null or missing") # Debug
	print("Game over screen displayed") # Debug

# Handle restart button to return to start menu
func _on_restart_pressed() -> void:
	print("Restart button pressed") # Debug
	get_tree().paused = false
	if get_tree().change_scene_to_file("res://start_menu.tscn") != OK:
		push_error("Failed to load start menu") # Debug
	queue_free()
