extends Area2D

@export var max_speed: float = 300.0
@export var acceleration: float = 500.0
@export var rotation_speed: float = 3.0
@export var max_fuel: float = 100.0
@export var fuel_consumption_rate: float = 10.0
@export var deceleration: float = 50.0

var velocity: Vector2 = Vector2.ZERO
var fuel: float
var inventory: Dictionary = {"minerals": 0, "ice": 0}

func _ready() -> void:
	fuel = max_fuel
	z_index = 1
	area_entered.connect(_on_area_entered)
	print("Ship initialized with fuel: ", fuel)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("ui_right"):
		rotation += rotation_speed * delta

	if Input.is_action_pressed("ui_up") and fuel > 0:
		var direction = Vector2.UP.rotated(rotation)
		velocity += direction * acceleration * delta
		velocity = velocity.limit_length(max_speed)
		fuel -= fuel_consumption_rate * delta
		if fuel <= 0:
			fuel = 0
			game_over()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	print("Ship collided with: ", area.name, " in group: ", area.get_groups())
	if area.is_in_group("pickups"):
		var pickup = area
		match pickup.resource_type:
			"fuel":
				fuel = max_fuel
				print("Collected fuel, new fuel: ", fuel)
			"minerals":
				inventory.minerals += 1
				print("Collected mineral, inventory: ", inventory)
			"ice":
				inventory.ice += 1
				print("Collected ice, inventory: ", inventory)
		pickup.queue_free()
	elif area.is_in_group("space_station"):
		var station = area
		station.store_resources(inventory)
		inventory = {"minerals": 0, "ice": 0}
		fuel = max_fuel
		print("Dropped off at station, inventory reset, fuel refilled: ", fuel)

func get_fuel_percentage() -> float:
	return fuel / max_fuel

func game_over() -> void:
	var game_over_scene = preload("res://game_over.tscn").instantiate()
	get_tree().current_scene.add_child(game_over_scene)
	print("Game over triggered")
