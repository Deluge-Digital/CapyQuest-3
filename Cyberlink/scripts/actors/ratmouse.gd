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
	
	var front_node = detect_front()
	var dead : bool = false
	var win : bool = false
	
	if front_node is Ground:
		if PlayerData.get_player_color() & front_node.get_color():
			front_node = null
		if front_node:
			var target_pos = sword_front.global_position - Vector3(0,9,0)
			global_position = target_pos
			rat_sprite.global_position = sword_back.global_position - Vector3(0,9,0)
			
			animation_tween = get_tree().create_tween()
			animation_tween.tween_property(rat_sprite,"global_position",target_pos,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			animator.play("Walk")
			
	if front_node is Wall:
		if PlayerData.get_player_color() & front_node.get_color():
			var target_pos = sword_front.global_position - Vector3(0,9,0)
			global_position = target_pos
			rat_sprite.global_position = sword_back.global_position - Vector3(0,9,0)
			
			animation_tween = get_tree().create_tween()
			animation_tween.tween_property(rat_sprite,"global_position",target_pos,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			animator.play("Walk")
			
	if front_node is Goal:
		win = true
		var target_pos = sword_front.global_position - Vector3(0,9,0)
		global_position = target_pos
		rat_sprite.global_position = sword_back.global_position - Vector3(0,9,0)
		
		animation_tween = get_tree().create_tween()
		animation_tween.tween_property(rat_sprite,"global_position",target_pos,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		animator.play("Walk")
		front_node.queue_free()
		animator.queue("Backflip")
		
	if front_node is Keycard:
		var target_pos = sword_front.global_position - Vector3(0,9,0)
		global_position = target_pos
		rat_sprite.global_position = sword_back.global_position - Vector3(0,9,0)
		
		animation_tween = get_tree().create_tween()
		animation_tween.tween_property(rat_sprite,"global_position",target_pos,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		animator.play("Walk")
		front_node.queue_free()
		PlayerData._add_keycard(front_node.tile_color)
		
	if front_node is Gate:
		if PlayerData.get_keycard_inventory() & front_node.get_color():
			var target_pos = sword_front.global_position - Vector3(0,9,0)
			global_position = target_pos
			rat_sprite.global_position = sword_back.global_position - Vector3(0,9,0)
			
			animation_tween = get_tree().create_tween()
			animation_tween.tween_property(rat_sprite,"global_position",target_pos,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			animator.play("Walk")
		
	if !front_node:
		dead = true
		
		var target_pos = sword_front.global_position - Vector3(0,9,0)
		global_position = target_pos
		rat_sprite.global_position = sword_back.global_position - Vector3(0,9,0)
		
		animation_tween = get_tree().create_tween()
		animation_tween.tween_property(rat_sprite,"global_position",target_pos,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		animator.play("Walk")
		animator.queue("Fall")
		
	await get_tree().process_frame
	is_moving = false
	if !dead && !win:
		get_parent().get_parent().request_waiting_state()
	if dead:
		get_parent().get_parent().request_dead_state()
	if win:
		get_parent().get_parent().request_win_state()
