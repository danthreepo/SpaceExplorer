extends Node2D

# Initialize timer signal
func _ready() -> void:
	if not has_node("LifetimeTimer"):
		push_error("LifetimeTimer node missing in PickupEffect") # Debug
		return
	if not has_node("Particles"):
		push_error("Particles node missing in PickupEffect") # Debug
		return
	if not $LifetimeTimer.timeout.is_connected(_on_lifetime_timer_timeout):
		$LifetimeTimer.timeout.connect(_on_lifetime_timer_timeout)
	if $Particles.emitting:
		print("Pickup effect spawned at: ", global_position, " emitting: ", $Particles.emitting) # Debug
	else:
		push_error("Pickup effect not emitting, check CPUParticles2D settings") # Debug

# Free effect after particle lifetime
func _on_lifetime_timer_timeout() -> void:
	print("Pickup effect freed at: ", global_position) # Debug
	queue_free()
