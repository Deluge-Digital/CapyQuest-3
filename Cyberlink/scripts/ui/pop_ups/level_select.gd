extends BasePopup
class_name LevelSelect

@export var grid : GridContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_parent() is MainMenu:
			get_parent()._back()
			queue_free()

func _ready() -> void:
	for each in grid.get_children():
		if each is Button:
			var n : int = int(each.name)
			each.pressed.connect(_on_level_pressed.bind(n))

func _on_level_pressed(level_num: int) -> void:
	if get_parent() is MainMenu:
		get_parent()._play_level(level_num)
