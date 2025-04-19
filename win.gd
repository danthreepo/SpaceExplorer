extends CanvasLayer

func _ready() -> void:
	if not $RestartButton.pressed.is_connected(_on_restart_pressed):
		$RestartButton.pressed.connect(_on_restart_pressed)
	get_tree().paused = true
	visible = true
	$ScoreLabel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property($ScoreLabel, "modulate", Color(1, 1, 1, 1), 0.5)
	$ScoreLabel.modulate = Color.GREEN
	await get_tree().create_timer(0.2).timeout
	$ScoreLabel.modulate = Color.WHITE
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
