extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		position.x -=8
		rotation_degrees.y = 0
	if event.is_action_pressed("ui_up"):
		position.z -=8
		rotation_degrees.y = -90
	if event.is_action_pressed("ui_down"):
		position.z +=8
		rotation_degrees.y = 90
	if event.is_action_pressed("ui_right"):
		position.x +=8
		rotation_degrees.y = 180
		
