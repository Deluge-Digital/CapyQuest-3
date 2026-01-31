extends Node3D
class_name LevelManager

## States
var menu_state : MenuState
var waiting_state : WaitingState

var state_machine : StateMachine

@export var camera : CameraControl

func _ready() -> void:
	_setup_state_machine()

func _setup_state_machine() -> void:
	var transitions : Dictionary = {
		MenuState.STATE_NAME : [WaitingState.STATE_NAME],
		WaitingState.STATE_NAME : [MenuState.STATE_NAME]
	}
	
	state_machine = StateMachine.new("level_state", transitions)
	
	menu_state = MenuState.new(state_machine)
	waiting_state = WaitingState.new(state_machine)
	
	menu_state.pass_camera(camera)
	waiting_state.pass_camera(camera)
	
	state_machine.transition_to(menu_state)
	
	
