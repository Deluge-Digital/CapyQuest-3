extends BaseLevel




func _ready() -> void:
	pass

func wincheck():
	if $Ratmouse.position == $Cheese.position:
		$Ratmouse/AnimationPlayer.play("Movement Anim")
		print("youwin!!")

func _input(event: InputEvent) -> void:
	print(str($Ratmouse/Raticus.position))
	wincheck()
	


func _on_animated_sprite_3d_animation_finished() -> void:
	$Camera3D/AnimatedSprite3D.pause()
