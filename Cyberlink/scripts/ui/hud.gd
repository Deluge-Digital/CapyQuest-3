extends BasePopup
class_name Hud

@export var red_mask : Button
@export var green_mask : Button
@export var blue_mask : Button

func _check_masks() -> void:
	if PlayerData.get_mask_inventory() & color_enum.TileColor.RED: red_mask.visible = true
	else: red_mask.visible = false
	
	if PlayerData.get_mask_inventory() & color_enum.TileColor.GREEN: green_mask.visible = true
	else: green_mask.visible = false
	
	if PlayerData.get_mask_inventory() & color_enum.TileColor.BLUE: blue_mask.visible = true
	else: blue_mask.visible = false
	

func _on_red_pressed():
	if PlayerData.get_mask_inventory() & color_enum.TileColor.RED:
		PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.RED) as color_enum.TileColor
		GameManager._update_color()

func _on_green_pressed():
	if PlayerData.get_mask_inventory() & color_enum.TileColor.GREEN:
		PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.GREEN) as color_enum.TileColor
		GameManager._update_color()

func _on_blue_pressed():
	if PlayerData.get_mask_inventory() & color_enum.TileColor.BLUE:
		PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.BLUE) as color_enum.TileColor
		GameManager._update_color()


func _on_menu_pressed():
	GameManager.request_main_menu()


func _on_retry_pressed():
	GameManager.level_manager._reset_level()


func _on_rotate_pressed():
	GameManager.level_manager._turn_camera_left()


func _on_view_pressed():
	GameManager.level_manager._change_rat_cam()
