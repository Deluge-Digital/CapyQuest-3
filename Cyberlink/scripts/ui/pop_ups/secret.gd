extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body. 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("press")
		$Camera3D/AnimatedSprite3D.play("default_2")
