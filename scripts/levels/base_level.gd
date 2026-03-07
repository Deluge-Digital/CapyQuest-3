extends Node3D
class_name BaseLevel

@export var starting_masks : color_enum.TileColor = color_enum.TileColor.NONE

func _ready() -> void:
	PlayerData._reset_mask_inventory()
	PlayerData._add_mask(starting_masks)
	await get_tree().process_frame
	GameManager._request_hud_refresh()
