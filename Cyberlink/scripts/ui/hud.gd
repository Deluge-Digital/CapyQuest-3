extends BasePopup
class_name Hud


func _on_red_pressed():
	PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.RED) as color_enum.TileColor
	GameManager._update_color()


func _on_green_pressed():
	PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.GREEN) as color_enum.TileColor
	GameManager._update_color()


func _on_blue_pressed():
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
