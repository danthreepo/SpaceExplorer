extends Area2D

@export var resource_type: String = "fuel"  # Options: fuel, minerals, ice

func _ready() -> void:
	add_to_group("pickups")
	# Set sprite based on type
	match resource_type:
		"fuel":
			$Sprite2D.texture = preload("res://fuel.png")
		"minerals":
			$Sprite2D.texture = preload("res://mineral.png")
		"ice":
			$Sprite2D.texture = preload("res://ice.png")
	print("Pickup spawned: ", resource_type, " at ", global_position)
