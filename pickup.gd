extends Area2D

# Configuration for pickup type
@export var resource_type: String = "minerals"  # Options: minerals, ice, fuel

# Set up pickup type and appearance
func _ready() -> void:
	add_to_group("pickups")
	match resource_type:
		"minerals":
			$Sprite2D.texture = preload("res://mineral.png")
			$Sprite2D.self_modulate = Color(0.7, 0.7, 0.7)  # Gray for minerals
		"ice":
			$Sprite2D.texture = preload("res://ice.png")
			$Sprite2D.self_modulate = Color(0.5, 0.7, 1.0)  # Blue for ice
		"fuel":
			$Sprite2D.texture = preload("res://fuel.png")
			$Sprite2D.self_modulate = Color(1.0, 1.0, 0.5)  # Yellow for fuel
		_:
			push_error("Invalid pickup type: ", resource_type) # Debug
	print("Pickup spawned: ", resource_type, " at ", global_position) # Debug
