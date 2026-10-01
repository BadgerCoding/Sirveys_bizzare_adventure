extends Node

func _ready() -> void:
	if not OS.has_feature("mobile"):
		DisplayServer.window_set_size(Vector2i(540, 960))
	SceneRouter.go.call_deferred("profile_setup" if not GameState.has_profile() else "main_menu")
