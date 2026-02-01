extends BasePopup
class_name LevelSelect

@export var grid : GridContainer
@export var animator : AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_exit()
	
func _exit() -> void:
	if get_parent() is MainMenu:
		animator.play("menu_off")
		get_parent()._back()
		await get_tree().create_timer(2.0).timeout
		queue_free()

func _ready() -> void:
	animator.play("menu_on")
	for each in grid.get_children():
		if each is Button:
			var n : int = int(each.name)
			each.pressed.connect(_on_level_pressed.bind(n))

func _on_level_pressed(level_num: int) -> void:
	if get_parent() is MainMenu:
		get_parent()._play_level(level_num)
