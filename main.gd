extends Node2D

@export var pickup_scene: PackedScene
@export var spawn_area_width: float = 2000.0
@export var spawn_area_height: float = 2000.0
@export var max_pickups: int = 10

var pickup_types = ["fuel", "minerals", "ice"]

func _ready() -> void:
	randomize()
	for i in range(max_pickups):
		spawn_pickup()

func _process(delta: float) -> void:
	$UI/FuelBar.value = $Ship.get_fuel_percentage()
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

func spawn_pickup() -> void:
	if get_tree().get_nodes_in_group("pickups").size() >= max_pickups:
		return
	var pickup = pickup_scene.instantiate()
	pickup.resource_type = pickup_types[randi() % pickup_types.size()]
	add_child(pickup)
	var x = randf_range(-spawn_area_width / 2, spawn_area_width / 2)
	var y = randf_range(-spawn_area_height / 2, spawn_area_height / 2)
	pickup.global_position = Vector2(x, y) + $SpaceStation.global_position
	print("Spawned pickup: ", pickup.resource_type, " at ", pickup.global_position)
