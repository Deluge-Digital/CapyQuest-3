extends Control
class_name MainMenu

@export var animator : AnimationPlayer

func _ready() -> void:
	animator.play("menu_on")

func _on_start_pressed() -> void:
	animator.play("menu_off")
	await get_tree().create_timer(2.0).timeout
	GameManager.request_play()
	GameManager.level_manager._ready_level(1)
	queue_free()
