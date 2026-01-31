extends BaseLevel




func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$Ratmouse/AnimationPlayer.play("Movement Anim")
		$Camera3D/AnimatedSprite3D.play("default_2")
	


func _on_animated_sprite_3d_animation_finished() -> void:
	$Camera3D/AnimatedSprite3D.pause()
