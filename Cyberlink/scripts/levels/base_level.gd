extends Node3D
class_name BaseLevel

var starting_position_x : int
var starting_position_z : int

var ground_scene : PackedScene = preload("res://scenes/props/ground.tscn")

func set_start_pos(start_pos_x : int, start_pos_z : int) -> void:
	starting_position_x = (start_pos_x * 8) - 4
	starting_position_z = (start_pos_z * 8) - 4

func generate_ground(ground_node : Ground) -> void:
	for each_x in ground_node.board_size_x:
		for each_z in ground_node.board_size_z:
			var new_ground : Ground = ground_scene.instantiate()
			new_ground.position = Vector3((each_x * 8.0) + 4.0, 0, (each_z * 8) + 4.0)
			add_child(new_ground)
			print(new_ground.global_position)
