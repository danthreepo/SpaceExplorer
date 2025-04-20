extends Area2D

# Configuration for movement and fuel
@export var speed: float = 400.0
@export var rotation_speed: float = 2.5
@export var fuel_depletion_rate: float = 5.0
@export var max_fuel: float = 100.0

# Ship state
var velocity: Vector2 = Vector2.ZERO
var fuel: float = max_fuel
var inventory = {"minerals": 0, "ice": 0}

# Initialize ship and signals
func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	add_to_group("ship")
	$ThrusterParticles.emitting = false
	if has_node("ThrusterSound"):
		print("ThrusterSound initialized, stream: ", $ThrusterSound.stream.resource_path) # Debug
	else:
		push_error("ThrusterSound node missing") # Debug
	print("Ship initialized, initial fuel: ", fuel) # Debug

# Handle movement, fuel, particles, and sound
func _physics_process(delta: float) -> void:
	var rotation_dir: float = Input.get_axis("ui_left", "ui_right")
	rotation += rotation_dir * rotation_speed * delta
	
	var thrust: float = Input.get_axis("ui_down", "ui_up")
	if thrust > 0 and fuel > 0:
		var direction = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
		velocity += direction * speed * thrust * delta
		fuel = max(0, fuel - fuel_depletion_rate * delta)
		$ThrusterParticles.emitting = true
		if has_node("ThrusterSound") and not $ThrusterSound.playing:
			$ThrusterSound.play()
			print("Thruster sound playing, volume: ", $ThrusterSound.volume_db) # Debug
	else:
		$ThrusterParticles.emitting = false
		if has_node("ThrusterSound") and $ThrusterSound.playing:
			$ThrusterSound.stop()
			print("Thruster sound stopped") # Debug
	
	global_position += velocity * delta
	
	if fuel <= 0 and not get_tree().paused:
		print("Fuel depleted, game over") # Debug
		var game_over_scene = preload("res://game_over.tscn").instantiate()
		get_parent().add_child(game_over_scene)
		get_parent().timer_active = false

# Provide fuel percentage for UI
func get_fuel_percentage() -> float:
	var percentage = (fuel / max_fuel) * 100.0
	# print("get_fuel_percentage called, returning: ", percentage) # Debug (Disabled)
	return percentage

# Handle collisions with pickups or space station
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickups"):
		print("Collided with pickup: ", area.resource_type, " at: ", area.global_position) # Debug
		var effect_scene = preload("res://pickup_effect.tscn")
		if effect_scene:
			var effect = effect_scene.instantiate()
			effect.global_position = area.global_position
			get_parent().add_child(effect)
			print("Spawned pickup effect at: ", effect.global_position) # Debug
		else:
			push_error("Failed to load pickup_effect.tscn") # Debug
		if area.resource_type == "fuel":
			fuel = max_fuel
			print("Collected fuel, new fuel: ", fuel, " percentage: ", get_fuel_percentage()) # Debug
		else:
			inventory[area.resource_type] += 1
			print("Collected ", area.resource_type, ", inventory: ", inventory) # Debug
		area.queue_free()
	elif area.is_in_group("space_station"):
		fuel = max_fuel
		print("Entered space station, calling store_resources") # Debug
		area.store_resources(inventory)
		inventory = {"minerals": 0, "ice": 0}
		print("Stored resources at station, inventory reset, fuel refilled: ", fuel) # Debug
