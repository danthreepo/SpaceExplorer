extends CanvasLayer

func _ready() -> void:
	if not $StartButton.pressed.is_connected(_on_start_button_pressed):
		$StartButton.pressed.connect(_on_start_button_pressed)
	if not $ResetScoreButton.pressed.is_connected(_on_reset_score_button_pressed):
		$ResetScoreButton.pressed.connect(_on_reset_score_button_pressed)
	load_high_score()
	visible = true
	print("Start menu displayed")

func load_high_score() -> void:
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		var high_score = file.get_var()
		file.close()
		$HighScoreLabel.text = "High Score: %d" % high_score
		print("Loaded high score: ", high_score)
	else:
		$HighScoreLabel.text = "High Score: 0"
		print("No high score file found")

func save_high_score(score: int) -> void:
	var current_high_score = 0
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		current_high_score = file.get_var()
		file.close()
	if score > current_high_score:
		var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
		file.store_var(score)
		file.close()
		print("Saved high score: ", score)

func _on_start_button_pressed() -> void:
	print("Start button pressed")
	get_tree().change_scene_to_file("res://main.tscn")

func _on_reset_score_button_pressed() -> void:
	print("Reset score button pressed")
	if FileAccess.file_exists("user://high_score.save"):
		DirAccess.remove_absolute("user://high_score.save")
		$HighScoreLabel.text = "High Score: 0"
		print("High score reset")
