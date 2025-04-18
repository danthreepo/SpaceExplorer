extends Area2D

var stored_inventory: Dictionary = {"minerals": 0, "ice": 0}

func _ready() -> void:
	add_to_group("space_station")
	print("Space station at: ", global_position)

func store_resources(inventory: Dictionary) -> void:
	stored_inventory.minerals += inventory.minerals
	stored_inventory.ice += inventory.ice
	print("Stored resources, total: ", stored_inventory)
