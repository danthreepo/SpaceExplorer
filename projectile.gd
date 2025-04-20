extends Area2D

# Configuration
@export var speed: float = 600.0
var direction: Vector2 = Vector2.UP

# Initialize
func _ready() -> void:
	add_to_group("projectiles")
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not has_node("VisibleOnScreenNotifier2D"):
		push_error("VisibleOnScreenNotifier2D node missing in Projectile") # Debug
	elif not $VisibleOnScreenNotifier2D.screen_exited.is_connected(_on_visible_on_screen_notifier_2d_screen_exited):
		$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	print("Projectile spawned at: ", global_position) # Debug

# Move projectile
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

# Handle collisions
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		print("Projectile hit mob at: ", area.global_position) # Debug
		area.queue_free()
		queue_free()

# Despawn off-screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Projectile despawned off-screen at: ", global_position) # Debug
	queue_free()
