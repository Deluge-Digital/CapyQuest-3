extends Node3D
class_name Rat

enum rat_dir {
	POSX,
	POSZ,
	NEGX,
	NEGZ
}

var rat_direction : rat_dir = rat_dir.NEGX
var state_machine : StateMachine
var animation_tween: Tween
var is_moving : bool = false

@export var sword_front : RayCast3D
@export var sword_right : RayCast3D
@export var sword_back : RayCast3D
@export var sword_left : RayCast3D
@export var rat_sprite : Node3D
@export var animator : AnimationPlayer

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
	if is_moving:
		return
	match event:
		"up":
			match cam_dir:
				0 : rat_direction = rat_dir.POSX
				1 : rat_direction = rat_dir.POSZ
				2 : rat_direction = rat_dir.NEGX
				3 : rat_direction = rat_dir.NEGZ
				_ : return
		"down":
			match cam_dir:
				0 : rat_direction = rat_dir.NEGX
				1 : rat_direction = rat_dir.NEGZ
				2 : rat_direction = rat_dir.POSX
				3 : rat_direction = rat_dir.POSZ
				_ : return
		"left":
			match cam_dir:
				0 : rat_direction = rat_dir.NEGZ
				1 : rat_direction = rat_dir.POSX
				2 : rat_direction = rat_dir.POSZ
				3 : rat_direction = rat_dir.NEGX
				_ : return
		"right":
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
	await get_tree().physics_frame
	_move_forward()

func _move_forward() -> void:
	is_moving = true
	if animation_tween && animation_tween.is_running():
		animation_tween.kill()
	rat_sprite.global_position = global_position
	animator.stop()
	await get_tree().physics_frame
	
	if detect_front() is Ground:
		
		var target_pos = sword_front.global_position - Vector3(0,9,0)
		global_position = target_pos
		rat_sprite.global_position = sword_back.global_position - Vector3(0,9,0)
		
		animation_tween = get_tree().create_tween()
		animation_tween.tween_property(rat_sprite,"global_position",target_pos,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		animator.play("Walk")
		
	await get_tree().process_frame
	is_moving = false
	var parent : LevelManager = get_parent().get_parent()
	parent.request_waiting_state()
