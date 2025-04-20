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
var sensor_active: bool = false
var sensor_cooldown: float = 0.0
const SENSOR_COOLDOWN_TIME: float = 5.0

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
	if has_node("WeaponSound"):
		print("WeaponSound initialized, stream: ", $WeaponSound.stream.resource_path) # Debug
	else:
		push_error("WeaponSound node missing") # Debug
	print("Ship initialized, initial fuel: ", fuel) # Debug

# Handle movement, fuel, particles, sound, weapon, and sensor
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
	
	if Input.is_action_just_pressed("fire_weapon"):
		fire_weapon()
	
	if Input.is_action_just_pressed("toggle_sensor"):
		sensor_active = not sensor_active
		print("Sensor toggled: ", sensor_active) # Debug
		get_tree().call_group("ui", "update_sensor_state", sensor_active)
	
	if Input.is_action_just_pressed("activate_sensor") and sensor_active and sensor_cooldown <= 0.0:
		activate_sensor()
		sensor_cooldown = SENSOR_COOLDOWN_TIME
		print("Sensor activated, cooldown started") # Debug
	
	if sensor_cooldown > 0.0:
		sensor_cooldown = max(0.0, sensor_cooldown - delta)
		get_tree().call_group("ui", "update_sensor_cooldown", sensor_cooldown / SENSOR_COOLDOWN_TIME)
	
	global_position += velocity * delta
	
	if fuel <= 0 and not get_tree().paused:
		print("Fuel depleted, game over") # Debug
		var game_over_scene = preload("res://game_over.tscn").instantiate()
		get_parent().add_child(game_over_scene)
		get_parent().timer_active = false

# Fire projectile
func fire_weapon() -> void:
	var projectile_scene = preload("res://projectile.tscn")
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = $Weapon.global_position
		projectile.global_rotation = rotation
		projectile.direction = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
		get_parent().add_child(projectile)
		if has_node("WeaponSound") and not $WeaponSound.playing:
			$WeaponSound.play()
			print("Weapon fired, sound playing at: ", $Weapon.global_position) # Debug
	else:
		push_error("Failed to load projectile.tscn") # Debug

# Activate sensor
func activate_sensor() -> void:
	var entities = get_tree().get_nodes_in_group("pickups") + get_tree().get_nodes_in_group("mobs") + get_tree().get_nodes_in_group("space_station")
	for entity in entities:
		if global_position.distance_to(entity.global_position) <= 1000.0:
			var screen_pos = get_viewport().get_camera_2d().unproject_position(entity.global_position)
			var viewport_size = get_viewport().size
			if screen_pos.x < 0 or screen_pos.x > viewport_size.x or screen_pos.y < 0 or screen_pos.y > viewport_size.y:
				# Entity is off-screen, add sensor arrow
				add_sensor_arrow(entity)
			else:
				# Entity is on-screen, highlight it
				entity.modulate = Color(1, 0.5, 0.5, 1)
				var timer = Timer.new()
				timer.wait_time = 2.0
				timer.one_shot = true
				timer.autostart = true
				timer.timeout.connect(func(): entity.modulate = Color(1, 1, 1, 1))
				add_child(timer)

# Add sensor arrow for off-screen entities
func add_sensor_arrow(entity: Node2D) -> void:
	var arrow_scene = preload("res://sensor_arrow.tscn")
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		var direction = (entity.global_position - global_position).normalized()
		var angle = direction.angle()
		var viewport_size = get_viewport().size
		var screen_pos = get_viewport().get_camera_2d().unproject_position(entity.global_position)
		# Place arrow on screen edge
		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				arrow.global_position = get_viewport().get_camera_2d().unproject_position(Vector2(0, clamp(screen_pos.y, 0, viewport_size.y)))
			else:
				arrow.global_position = get_viewport().get_camera_2d().unproject_position(Vector2(viewport_size.x, clamp(screen_pos.y, 0, viewport_size.y)))
		else:
			if direction.y < 0:
				arrow.global_position = get_viewport().get_camera_2d().unproject_position(Vector2(clamp(screen_pos.x, 0, viewport_size.x), 0))
			else:
				arrow.global_position = get_viewport().get_camera_2d().unproject_position(Vector2(clamp(screen_pos.x, 0, viewport_size.x), viewport_size.y))
		arrow.rotation = angle
		get_parent().add_child(arrow)
		print("Sensor arrow spawned for entity at: ", entity.global_position) # Debug
		var timer = Timer.new()
		timer.wait_time = 2.0
		timer.one_shot = true
		timer.autostart = true
		timer.timeout.connect(func(): arrow.queue_free())
		add_child(timer)
	else:
		push_error("Failed to load sensor_arrow.tscn") # Debug

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
			#print("Collected fuel, new fuel: ", fuel, " percentage: ", get_fuel_percentage()) # Debug
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
