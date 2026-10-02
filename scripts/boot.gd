extends Node
# Entry point. Also the scene Godot reloads when the story/RPG scene hands control back to the app.

func _ready() -> void:
	SceneRouter.go.call_deferred("profile_setup" if not GameState.has_profile() else "main_menu")
