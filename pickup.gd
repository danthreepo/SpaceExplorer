extends Area2D

@export var resource_type: String = "minerals"  # Options: minerals, ice, fuel

func _ready() -> void:
	add_to_group("pickups")
	match resource_type:
		"minerals":
			$Sprite2D.texture = preload("res://mineral.png")
		"ice":
			$Sprite2D.texture = preload("res://ice.png")
		"fuel":
			$Sprite2D.texture = preload("res://fuel.png")
		_:
			push_error("Invalid pickup type: ", resource_type)
	print("Pickup spawned: ", resource_type, " at ", global_position)
