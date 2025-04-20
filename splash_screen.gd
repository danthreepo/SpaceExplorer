extends Node2D

# Initialize animation
func _ready() -> void:
	if not $AnimationPlayer.animation_finished.is_connected(_on_animation_player_animation_finished):
		$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)
	if $AnimationPlayer.has_animation("fade"):
		$AnimationPlayer.play("fade")
		print("Splash screen fade animation started") # Debug
	else:
		push_error("Fade animation missing in AnimationPlayer") # Debug

# Transition to start menu after animation
func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade":
		print("Splash screen animation finished, loading start menu") # Debug
		var start_menu = preload("res://start_menu.tscn")
		if start_menu:
			get_tree().change_scene_to_packed(start_menu)
		else:
			push_error("Failed to load start_menu.tscn") # Debug
