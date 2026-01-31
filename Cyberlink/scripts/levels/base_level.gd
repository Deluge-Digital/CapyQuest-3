extends Node3D
class_name BaseLevel

var starting_position_x : int
var starting_position_z : int

var ground_scene : PackedScene = preload("res://scenes/props/ground.tscn")

func set_start_pos(start_pos_x : int, start_pos_z : int) -> void:
	starting_position_x = (start_pos_x * 8) - 4
	starting_position_z = (start_pos_z * 8) - 4
