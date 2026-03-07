extends ProgressBar

@export_file("*.wav") var onHover
@export_file("*.wav") var onValueChange

func _on_focus_entered():
	GlobalSoundmanager.playSFX(onHover)
	
func _on_mouse_entered():
	GlobalSoundmanager.playSFX(onHover)

func _on_value_changed(_value):
	GlobalSoundmanager.playSFX(onValueChange)
