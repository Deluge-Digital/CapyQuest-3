extends RefCounted
class_name PopupLibrary

const _BLOCKER = preload("res://scenes/ui/pop_ups/blocker.tscn")
const _GENERIC = preload("res://scenes/ui/pop_ups/generic_popup.tscn")
const _HUD = preload("res://scenes/ui/pop_ups/hud.tscn")
const _LEVEL_SELECT = preload("res://scenes/ui/pop_ups/level_select.tscn")


static func create_popup(popup_type: int, params: Dictionary = {}) -> BasePopup:
	var popup: BasePopup
	
	match popup_type:
		2:
			popup = _HUD.instantiate()
		_:
			popup = _GENERIC.instantiate()
	
	popup.set_params(params)
	return popup

static func create_blocker() -> Blocker:
	var blocker = _BLOCKER.instantiate()
	return blocker
