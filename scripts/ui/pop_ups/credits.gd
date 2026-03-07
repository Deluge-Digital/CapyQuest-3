extends BasePopup
class_name Credits

@export var animator : AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_exit()

func _on_ready() -> void:
	animator.play("menu_on")
	
func _exit() -> void:
	if get_parent() is MainMenu:
		animator.play("menu_off")
		get_parent()._back()
		await get_tree().create_timer(2.0).timeout
		queue_free()

func _on_cool_pressed() -> void:
	_exit()
