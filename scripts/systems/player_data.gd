extends Node

var player_color : color_enum.TileColor = color_enum.TileColor.NONE
var player_keycard_inventory : color_enum.TileColor = color_enum.TileColor.NONE
var player_mask_inventory : color_enum.TileColor = color_enum.TileColor.NONE

func _reset_keycard_inventory() -> void:
	player_keycard_inventory = color_enum.TileColor.NONE
	
func _add_keycard(card : color_enum.TileColor) -> void:
	player_keycard_inventory = (player_keycard_inventory | card) as color_enum.TileColor
	
func get_keycard_inventory() -> color_enum.TileColor:
	return player_keycard_inventory
	
func _reset_mask_inventory() -> void:
	player_mask_inventory = color_enum.TileColor.NONE
	
func _add_mask(card : color_enum.TileColor) -> void:
	player_mask_inventory = (player_keycard_inventory | card) as color_enum.TileColor
	
func get_mask_inventory() -> color_enum.TileColor:
	return player_mask_inventory

func get_player_color() -> color_enum.TileColor:
	return player_color

func set_player_color() -> void:
	pass
