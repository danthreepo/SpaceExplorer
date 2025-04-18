extends Area2D

var stored_inventory: Dictionary = {"minerals": 0, "ice": 0}
signal win_game

func _ready() -> void:
	add_to_group("space_station")
	print("Space station at: ", global_position)

func store_resources(inventory: Dictionary) -> void:
	stored_inventory.minerals += inventory.minerals
	stored_inventory.ice += inventory.ice
	print("Stored resources, total: ", stored_inventory)
	if stored_inventory.minerals >= 8 and stored_inventory.ice >= 8:
		emit_signal("win_game")
		print("Win condition met: 8 minerals, 8 ice")
