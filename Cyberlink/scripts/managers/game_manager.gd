extends Node

func _ready() -> void:
	# Check to see if the current scene is the default. If so, kill it.
	# This script is attached to an autoload, so it can't also be the initial
	# 	scene as it would have two instances going at once.
	var default = get_tree().current_scene
	if default and default.name == "default":
		print("Current scene is default, freeing it.")
		default.queue_free()
	
	var _main_scene = get_tree().current_scene
