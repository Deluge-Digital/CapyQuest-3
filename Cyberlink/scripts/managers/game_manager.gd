extends Node

## States
var play_state : PlayState
var pause_state : PauseState
var main_menu_state : MainMenuState

var state_machine : StateMachine

func _ready() -> void:
	# Check to see if the current scene is the default. If so, kill it.
	# This script is attached to an autoload, so it can't also be the initial
	# 	scene as it would have two instances going at once.
	var default = get_tree().current_scene
	if default and default.name == "default":
		print("Current scene is default, freeing it.")
		default.queue_free()
	
	var _main_scene = get_tree().current_scene
	
	_setup_state_machine()

func _setup_state_machine() -> void:
	var transitions : Dictionary = {
		MainMenuState.STATE_NAME : [PlayState.STATE_NAME],
		PlayState.STATE_NAME : [MainMenuState.STATE_NAME],
		PauseState.STATE_NAME : [PlayState.STATE_NAME],
	}
	
	state_machine = StateMachine.new("game_state", transitions)
	
	main_menu_state = MainMenuState.new(state_machine)
	play_state = PlayState.new(state_machine)
	pause_state = PauseState.new(state_machine)
	
	state_machine.transition_to(main_menu_state)
