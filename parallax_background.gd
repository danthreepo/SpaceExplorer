extends ParallaxBackground

@export var scroll_speed: float = 50.0  # Adjust as needed

func _process(delta: float) -> void:
	scroll_offset.x += scroll_speed * delta
