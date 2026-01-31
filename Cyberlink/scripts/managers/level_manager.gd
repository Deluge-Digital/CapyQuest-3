extends Node3D
class_name LevelManager

## States
var disabled_state : DisabledState
var waiting_state : WaitingState

var state_machine : StateMachine

func _ready() -> void:
	_setup_state_machine()

func _setup_state_machine() -> void:
	var transitions : Dictionary = {
		
	}
	
	state_machine = StateMachine.new("level_state", transitions)
	
	waiting_state = WaitingState.new(state_machine)
	
	state_machine.transition_to(disabled_state)
