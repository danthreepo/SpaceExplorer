extends Node2D

# Configuration
@export var pickup_count: int = 8
@export var mob_count: int = 5

# References
var timer_active: bool = true

# Initialize game
func _ready() -> void:
	if not has_node("Timer"):
		push_error("Timer node missing in Main") # Debug
	else:
		print("Timer initialized, wait time: ", $Timer.wait_time) # Debug
	spawn_pickups()
	spawn_mobs()
	$BackgroundMusic.play()
	print("Main initialized, FuelBar: ", $UI/FuelBar) # Debug

# Spawn pickups
func spawn_pickups() -> void:
	var pickup_scene = preload("res://pickup.tscn")
	for type in ["minerals", "ice", "fuel"]:
		for i in range(pickup_count):
			var pickup = pickup_scene.instantiate()
			pickup.resource_type = type
			pickup.global_position = generate_random_position()
			pickup.modulate = Color(0.7, 0.7, 0.7) if type == "minerals" else Color(0.5, 0.5, 1.0) if type == "ice" else Color(1.0, 1.0, 0.5)
			add_child(pickup)
			print("Pickup spawned: ", type, " at: ", pickup.global_position) # Debug

# Spawn mobs
func spawn_mobs() -> void:
	var mob_scene = preload("res://mob.tscn")
	for i in range(mob_count):
		var mob = mob_scene.instantiate()
		mob.global_position = generate_random_position()
		add_child(mob)
		print("Mob spawned at: ", mob.global_position) # Debug

# Generate random position
func generate_random_position() -> Vector2:
	var angle = randf() * 2 * PI
	var distance = randf_range(500, 1500)
	return Vector2(cos(angle) * distance, sin(angle) * distance)

# Handle music loop
func _on_background_music_finished() -> void:
	$BackgroundMusic.play()
	print("Background music looped") # Debug

# Handle timer
func _process(delta: float) -> void:
	var station_pos = $SpaceStation.global_position
	var ship_pos = $Ship.global_position
	var distance = ship_pos.distance_to(station_pos)
	$UI/CompassDistance.text = "%d m" % distance
	if distance > 100.0:
		$UI/CompassArrow.visible = true
		var direction = (station_pos - ship_pos).normalized()
		$UI/CompassArrow.rotation = direction.angle() - PI / 2  # Adjust for upward-pointing arrow
		print("Compass direction: ", direction, " angle: ", direction.angle()) # Debug
	else:
		$UI/CompassArrow.visible = false
	if timer_active and $Timer.time_left > 0:
		$UI/TimeLabel.text = "Time: %.1f" % $Timer.time_left
	elif timer_active and $Timer.time_left <= 0:
		timer_active = false
		$TimerSound.stop()
		var game_over_scene = preload("res://game_over.tscn").instantiate()
		add_child(game_over_scene)
		print("Game over, timer expired") # Debug

# Handle win condition
func _on_space_station_win_game() -> void:
	timer_active = false
	$TimerSound.stop()
	var time_score = max(0, $Timer.time_left)
	var win_scene = preload("res://win.tscn").instantiate()
	win_scene.time_score = time_score
	add_child(win_scene)
	print("Win! Time score: ", time_score) # Debug
