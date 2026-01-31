extends BaseLevel

func _ready() -> void:
	print("print")
	pass
	   
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("press")
		$Ratmouse/AnimationPlayer.play("Movement Anim")
		$Camera3D/AnimatedSprite3D.play("default_2")
