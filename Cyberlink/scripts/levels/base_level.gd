extends Node3D
class_name BaseLevel

var starting_position : Vector2

func _init(start_pos : Vector2) -> void:
	starting_position = start_pos * 8
