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
	
func _request_movement(event : InputEvent, move_dir : int):
	pass
