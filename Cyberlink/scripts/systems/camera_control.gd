extends Camera3D
class_name CameraControl

var move_tween

@export var default_duration : float = 0.6
@export var default_trans : Tween.TransitionType = Tween.TRANS_SINE
@export var default_ease : Tween.EaseType = Tween.EASE_IN_OUT

@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match", "shadowed_global_identifier")
func request_pose(target_pos : Vector3 = Vector3(9999,9999,9999), target_rot_deg : Vector3 = Vector3(9999,9999,9999), duration : float = 1.0, trans : Tween.TransitionType = -1, ease : Tween.EaseType = -1) -> void:
	if target_pos || target_rot_deg == Vector3(9999,9999,9999):
		return
	if duration < 0.0:
		duration = default_duration
	if trans == -1:
		trans = default_trans
	if ease == -1:
		ease = default_ease
	
	_interrupt_current_tween()
	
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
