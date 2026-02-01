extends BasePopup
class_name Settings

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_parent() is MainMenu:
			get_parent()._back()
			queue_free()
