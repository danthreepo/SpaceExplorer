extends CanvasLayer

func _ready() -> void:
	if not $RestartButton.pressed.is_connected(_on_restart_pressed):
		$RestartButton.pressed.connect(_on_restart_pressed)
	get_tree().paused = true
	visible = true
	print("Win screen displayed")

func set_score(total_score: int, time_taken: float, pickup_score: int, fuel_bonus: int) -> void:
	var time_score = total_score - pickup_score - fuel_bonus
	$ScoreLabel.text = "You Win!\nTime Taken: %.1fs\nTime Score: %d\nPickups: %d\nFuel Bonus: %d\nTotal Score: %d" % [time_taken, time_score, pickup_score, fuel_bonus, total_score]
	print("Score set: ", $ScoreLabel.text)

func _on_restart_pressed() -> void:
	print("Restart button pressed")
	get_tree().paused = false
	if get_tree().change_scene_to_file("res://start_menu.tscn") != OK:
		push_error("Failed to load start menu")
	queue_free()
