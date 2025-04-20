extends ParallaxBackground

# Configuration for scroll speed
@export var scroll_speed: float = 50.0  # Adjust as needed

# Scroll background every frame
func _process(delta: float) -> void:
	scroll_offset.x += scroll_speed * delta
