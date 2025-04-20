extends Area2D

# Configuration
@export var speed: float = 100.0
var target: Node2D = null

# Initialize
func _ready() -> void:
	add_to_group("mobs")
	print("Mob spawned at: ", global_position) # Debug

# Move toward ship
func _physics_process(delta: float) -> void:
	if not target:
		target = get_tree().get_first_node_in_group("ship")
	if target:
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
