extends Area2D

# Signal for win condition
signal win_game

# Stored resources
var stored_inventory = {"minerals": 0, "ice": 0}

# Initialize space station
func _ready() -> void:
	if $SpaceStationSound.stream:
		print("SpaceStationSound stream loaded: ", $SpaceStationSound.stream.resource_path) # Debug
	else:
		push_error("SpaceStationSound stream missing") # Debug
	if $AmbientSound.stream:
		print("AmbientSound stream loaded: ", $AmbientSound.stream.resource_path) # Debug
	else:
		push_error("AmbientSound stream missing") # Debug
	print("Space station initialized") # Debug

# Process proximity audio
func _process(delta: float) -> void:
	var ship = get_tree().get_first_node_in_group("ship")
	if ship:
		var distance = global_position.distance_to(ship.global_position)
		if distance <= 500.0 and not $AmbientSound.playing:
			$AmbientSound.play()
			print("Ambient sound started, distance: ", distance) # Debug
		elif distance > 500.0 and $AmbientSound.playing:
			$AmbientSound.stop()
			print("Ambient sound stopped, distance: ", distance) # Debug

# Store ship’s resources, play docking sound, and check for win
func store_resources(inventory: Dictionary) -> void:
	stored_inventory["minerals"] += inventory["minerals"]
	stored_inventory["ice"] += inventory["ice"]
	if $SpaceStationSound.stream and not $SpaceStationSound.playing:
		$SpaceStationSound.play()
		print("Docking sound played, volume: ", $SpaceStationSound.volume_db) # Debug
	else:
		push_error("Cannot play docking sound, stream missing or already playing") # Debug
	print("Stored resources: ", stored_inventory) # Debug
	if stored_inventory["minerals"] >= 8 and stored_inventory["ice"] >= 8:
		print("Win condition met, emitting win_game signal") # Debug
		win_game.emit()
