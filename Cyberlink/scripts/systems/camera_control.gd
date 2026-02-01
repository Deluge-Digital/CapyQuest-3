extends Camera3D
class_name CameraControl

var move_tween

enum mode {
	POSX,
	POSZ,
	NEGX,
	NEGZ
}

var level_size_x : float = 0.0
var level_size_z : float = 0.0
var rat : Rat

@export var default_duration : float = 0.6
@export var default_trans : Tween.TransitionType = Tween.TRANS_SINE
@export var default_ease : Tween.EaseType = Tween.EASE_IN_OUT

@export var border_pad : float = 4.0
@export var orbit_height : float = 25.0
@export var rat_height : float = 15.0
@export var orbit_radius_scale : float = 1.5

@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match", "shadowed_global_identifier")
func request_pose(target_pos : Vector3, target_rot_deg : Vector3, duration : float = 1.0, trans : Tween.TransitionType = -1, ease : Tween.EaseType = -1) -> void:
	if duration < 0.0:
		duration = default_duration
	if trans == -1:
		trans = default_trans
	if ease == -1:
		ease = default_ease
	
	_interrupt_current_tween()
	
	print(
		"Camera movement from pos:", global_position,
		"\n                from rot:", global_rotation_degrees,
		"\n                to pos:", target_pos,
		"\n                to rot:", target_rot_deg
	)
	
	var from_q : Quaternion = global_transform.basis.get_rotation_quaternion()
	var to_q : Quaternion = Quaternion.from_euler(target_rot_deg * PI / 180.0)
	
	move_tween = create_tween()
	move_tween.set_trans(trans)
	move_tween.set_ease(ease)
	move_tween.tween_property(self, "global_position", target_pos, duration)
	
	move_tween.parallel().tween_method(
		func(t : float) -> void:
			var q : Quaternion = from_q.slerp(to_q, t)
			global_transform = Transform3D(Basis(q), global_position),
		0.0, 1.0, duration
	)
	
func interrupt() -> void:
	_interrupt_current_tween()

func is_transitioning() -> bool:
	return move_tween != null and move_tween.is_running()

func _interrupt_current_tween() -> void:
	if move_tween != null:
		move_tween.kill()
		move_tween = null

func _hook_rat(incoming_rat : Rat) -> void:
	rat = incoming_rat

func _hook_level_size(level : Node) -> void:
	var max_x : float = 0.0
	var max_z : float = 0.0
	for child in level.get_children():
		if child is Ground:
			if child.global_position.x > max_x:
				max_x = child.global_position.x
			if child.global_position.z > max_z:
				max_z = child.global_position.z
	
	level_size_x = max_x + 4.0
	level_size_z = max_z + 4.0
	
func get_level_center() -> Vector3:
	return Vector3(level_size_x * 0.5, 0, level_size_z * 0.5)
	
func get_orbit_radius() -> float:
	var half_extent : float = max(level_size_x, level_size_z) * 0.5
	return max(1.0, half_extent * orbit_radius_scale)
	
func look_at_rot_deg(from_pos: Vector3, to_pos: Vector3) -> Vector3:
	print(from_pos, to_pos)
	var deg : Vector3
	
	var dir = (to_pos - from_pos).normalized()
	deg = Basis.looking_at(dir, Vector3.UP).get_euler() * 180.0 / PI
	
	return deg
	
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match", "shadowed_global_identifier")
func _turn_level_camera(side : mode = 0, duration : float = -1.0, trans : Tween.TransitionType = -1, ease: Tween.EaseType = -1) -> void:
	var center : Vector3 = get_level_center()
	var radius : float = get_orbit_radius()
	
	var target_pos = center
	
	match side:
		mode.POSX:
			target_pos.x -= radius
		mode.POSZ:
			target_pos.z -= radius
		mode.NEGX:
			target_pos.x += radius
		mode.NEGZ:
			target_pos.z += radius
			
	target_pos.y = orbit_height
	var target_rot_deg : Vector3 = look_at_rot_deg(target_pos, center)

	request_pose(target_pos, target_rot_deg, duration, trans, ease)
	
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match", "shadowed_global_identifier")
func _look_at_rat(side : mode = 0, duration : float = -1.0, trans : Tween.TransitionType = -1, ease: Tween.EaseType = -1) -> void:
	var radius : float = get_orbit_radius()
	
	var target_pos = rat.global_position
	
	match side:
		mode.POSX:
			target_pos.x -= radius
		mode.POSZ:
			target_pos.z -= radius
		mode.NEGX:
			target_pos.x += radius
		mode.NEGZ:
			target_pos.z += radius
			
	target_pos.y = rat_height
	var target_rot_deg : Vector3 = look_at_rot_deg(target_pos, rat.global_position)

	request_pose(target_pos, target_rot_deg, duration, trans, ease)
