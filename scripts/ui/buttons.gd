extends Button

@export_file("*.wav") var onHover
@export_file("*.wav") var onSelect

func _on_focus_entered():
	GlobalSoundmanager.playSFX(onHover)
	
func _on_mouse_entered():
	GlobalSoundmanager.playSFX(onHover)

func _on_pressed():
	GlobalSoundmanager.playSFX(onSelect)
