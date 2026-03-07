extends Control
class_name MainMenu

@export var title : Control
@export var animator : AnimationPlayer
@export var level_select : PackedScene
@export var settings : PackedScene
@export var credits : PackedScene

func _ready() -> void:
	if OS.has_feature("web"):
		$Title/VBoxContainer/MENU/VBoxContainer/END.visible = false
	animator.play("menu_on")
	
func _back() -> void:
	title.visible = true
	animator.play("menu_on")

func _play_level(level : int) -> void:
	animator.play("menu_off")
	await get_tree().create_timer(2.0).timeout
	GameManager.request_play()
	GameManager.level_manager._ready_level(level)
	queue_free()

func _on_start_pressed() -> void:
	_play_level(1)

func _on_levels_pressed() -> void:
	animator.play("menu_off")
	var new_scene = level_select.instantiate()
	add_child(new_scene)
	await get_tree().create_timer(2.0).timeout
	title.visible = false

func _on_settings_pressed() -> void:
	animator.play("menu_off")
	var new_scene = settings.instantiate()
	add_child(new_scene)
	await get_tree().create_timer(2.0).timeout
	title.visible = false

func _on_credits_pressed() -> void:
	animator.play("menu_off")
	var new_scene = credits.instantiate()
	add_child(new_scene)
	await get_tree().create_timer(2.0).timeout
	title.visible = false
	

func _on_end_pressed() -> void:
	get_tree().queue_free()
