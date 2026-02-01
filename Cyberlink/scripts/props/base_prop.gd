extends Area3D
class_name BaseProp

@export var tile_color: color_enum.TileColor = color_enum.TileColor.BLOCK

func _update_visibility() -> void:
	if PlayerData.get_player_color() & tile_color:
		self.visible = false
	else:
		self.visible = true

func get_color() -> color_enum.TileColor:
	return tile_color
