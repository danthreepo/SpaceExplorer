extends Node2D

# Configuration and state variables
@export var pickup_scene: PackedScene
@export var spawn_area_width: float = 2000.0
@export var spawn_area_height: float = 2000.0
@export var max_time: float = 60.0

var pickup_types = ["minerals", "ice", "fuel"]
var pickups_spawned = {"minerals": 0, "ice": 0, "fuel": 0}
var max_pickups_per_type = 8
var game_start_time: float
var score: int = 0
var time_remaining: float
var timer_active: bool = true

# Set up initial game state and spawn pickups
func _ready() -> void:
	randomize()
	game_start_time = Time.get_ticks_msec() / 1000.0
	time_remaining = max_time
	for type in pickup_types:
		for i in range(max_pickups_per_type):
			spawn_pickup(type)
	$SpaceStation.win_game.connect(_on_win_game)
	$Ship.area_entered.connect(_on_ship_area_entered)
	print("Main initialized, FuelBar: ", $UI/FuelBar) # Debug

# Update UI and timer every frame
func _process(_delta: float) -> void:
	var fuel_pct = $Ship.get_fuel_percentage()
	$UI/FuelBar.value = fuel_pct
	# print("Fuel percentage: ", fuel_pct, " FuelBar value: ", $UI/FuelBar.value) # Debug (Disabled)
	var inv = $Ship.inventory
	var stored = $SpaceStation.stored_inventory
	$UI/InventoryLabel.text = "Carried: %d minerals, %d ice\nStored: %d minerals, %d ice" % [inv.minerals, inv.ice, stored.minerals, stored.ice]
	var station_pos = $SpaceStation.global_position
	var ship_pos = $Ship.global_position
	var distance = ship_pos.distance_to(station_pos)
	$UI/CompassDistance.text = "%d m" % distance
	if distance > 100.0:
		$UI/CompassArrow.visible = true
		var direction = (station_pos - ship_pos).normalized()
		$UI/CompassArrow.rotation = direction.angle()
	else:
		$UI/CompassArrow.visible = false
	
	if timer_active:
		time_remaining = max(0.0, max_time - (Time.get_ticks_msec() / 1000.0 - game_start_time))
		$UI/TimeLabel.text = "Time: %.1fs" % time_remaining
		if time_remaining <= 0.0:
			if $TimerSound.playing:
				$TimerSound.stop()
		elif time_remaining < 10.0:
			$UI/TimeLabel.modulate = Color.RED
			if not $TimerSound.playing:
				$TimerSound.play()
		else:
			$UI/TimeLabel.modulate = Color.WHITE
			if $TimerSound.playing:
				$TimerSound.stop()

# Spawn a pickup at a random position 500-1500 units from space station
func spawn_pickup(type: String) -> void:
	if pickups_spawned[type] >= max_pickups_per_type:
		return
	var pickup = pickup_scene.instantiate()
	pickup.resource_type = type
	add_child(pickup)
	var distance = randf_range(500.0, 1500.0)
	var angle = randf_range(0, 2 * PI)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	pickup.global_position = $SpaceStation.global_position + offset
	pickups_spawned[type] += 1
	print("Spawned pickup: ", type, " at ", pickup.global_position) # Debug

# Save high score to file
func save_high_score(new_score: int) -> void:
	var current_high_score = 0
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		current_high_score = file.get_var()
		file.close()
	if new_score > current_high_score:
		var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
		file.store_var(new_score)
		file.close()
		print("Saved high score: ", new_score) # Debug

# Process win condition and show win screen
func _on_win_game() -> void:
	timer_active = false
	var time_taken = max_time - time_remaining
	var time_score = int(time_remaining * 100)
	var pickup_score = ($SpaceStation.stored_inventory.minerals + $SpaceStation.stored_inventory.ice) * 100
	var fuel_bonus = 0
	for pickup in get_tree().get_nodes_in_group("pickups"):
		if pickup.resource_type == "fuel":
			fuel_bonus += 500
	score = time_score + pickup_score + fuel_bonus
	print("Win! Time score: ", time_score, " Pickup score: ", pickup_score, " Fuel bonus: ", fuel_bonus, " Total: ", score) # Debug
	save_high_score(score)
	
	var win_scene = preload("res://win.tscn").instantiate()
	win_scene.set_score(score, time_taken, pickup_score, fuel_bonus)
	add_child(win_scene)

# Check win condition on ship entering space station
func _on_ship_area_entered(area: Area2D) -> void:
	if area.is_in_group("space_station") and $SpaceStation.stored_inventory.minerals >= 8 and $SpaceStation.stored_inventory.ice >= 8:
		timer_active = false
