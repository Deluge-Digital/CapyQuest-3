extends Control

func _on_start_pressed() -> void:
	if GameManager.request_play():
		GameManager.level_manager._ready_level(0)
		queue_free()
