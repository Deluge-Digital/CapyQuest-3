extends Node3D
class_name Rat

enum rat_dir {
	POSX,
	POSZ,
	NEGX,
	NEGZ
}

var rat_direction : rat_dir = rat_dir.NEGX

@export var sword_front : RayCast3D
@export var sword_right : RayCast3D
@export var sword_back : RayCast3D
@export var sword_left : RayCast3D

func detect_front() -> Node:
	if sword_front.is_colliding():
		return sword_front.get_collider()
	return null
	
func detect_right() -> Node:
	if sword_right.is_colliding():
		return sword_right.get_collider()
	return null
	
func detect_back() -> Node:
	if sword_back.is_colliding():
		return sword_back.get_collider()
	return null
	
func detect_left() -> Node:
	if sword_left.is_colliding():
		return sword_left.get_collider()
	return null
	
func _request_movement(event : String, cam_dir : int) -> void:
	match event:
		"ui_up":
			match cam_dir:
				0 : rat_direction = rat_dir.POSX
				1 : rat_direction = rat_dir.POSZ
				2 : rat_direction = rat_dir.NEGX
				3 : rat_direction = rat_dir.NEGZ
				_ : return
		"ui_down":
			match cam_dir:
				0 : rat_direction = rat_dir.NEGX
				1 : rat_direction = rat_dir.NEGZ
				2 : rat_direction = rat_dir.POSX
				3 : rat_direction = rat_dir.POSZ
				_ : return
		"ui_left":
			match cam_dir:
				0 : rat_direction = rat_dir.NEGZ
				1 : rat_direction = rat_dir.POSX
				2 : rat_direction = rat_dir.POSZ
				3 : rat_direction = rat_dir.NEGX
				_ : return
		"ui_right":
			match cam_dir:
				0 : rat_direction = rat_dir.POSZ
				1 : rat_direction = rat_dir.NEGX
				2 : rat_direction = rat_dir.NEGZ
				3 : rat_direction = rat_dir.POSX
				_ : return
		_ : return
		
	_update_rat_direction()
	
func _update_rat_direction() -> void:
	rotation_degrees.y = (rat_direction * -90.0) + 180
	await get_tree().process_frame
	_move_forward()
	
func _move_forward() -> void:
	if detect_front() is Ground:
		global_position = sword_front.global_position - Vector3(0,9,0)
