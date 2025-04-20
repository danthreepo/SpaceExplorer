extends CanvasLayer

# Initialize
func _ready() -> void:
	add_to_group("ui")
	update_sensor_state(false)
	update_sensor_cooldown(1.0)
	print("UI initialized, SensorCooldownBar: ", $SensorCooldownBar) # Debug

# Update sensor state label
func update_sensor_state(active: bool) -> void:
	$SensorStateLabel.text = "Sensor: " + ("On" if active else "Off")
	print("Sensor state updated: ", $SensorStateLabel.text) # Debug

# Update sensor cooldown bar
func update_sensor_cooldown(progress: float) -> void:
	$SensorCooldownBar.value = progress
	print("Sensor cooldown updated: ", progress) # Debug
