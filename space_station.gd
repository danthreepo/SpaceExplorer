extends Area2D

# Signal for win condition
signal win_game

# Stored resources
var stored_inventory = {"minerals": 0, "ice": 0}

# Initialize space station
func _ready() -> void:
	print("Space station initialized") # Debug

# Store ship’s resources and check for win
func store_resources(inventory: Dictionary) -> void:
	stored_inventory["minerals"] += inventory["minerals"]
	stored_inventory["ice"] += inventory["ice"]
	print("Stored resources: ", stored_inventory) # Debug
	if stored_inventory["minerals"] >= 8 and stored_inventory["ice"] >= 8:
		print("Win condition met, emitting win_game signal") # Debug
		win_game.emit()
