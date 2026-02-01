extends Node3D
class_name LevelManager

## States
var menu_state : MenuState
var waiting_state : WaitingState
var move_state : MoveState
var win_state : WinState
var dead_state : DeadState

var state_machine : StateMachine

@export var camera : CameraControl

var move_inputs : Dictionary = {
	"ui_up" : false,
	"up_down" : false,
	"ui_left" : false,
	"up_right" : false
}

func _ready() -> void:
	_setup_state_machine()

func _setup_state_machine() -> void:
	var transitions : Dictionary = {
		MenuState.STATE_NAME : [WaitingState.STATE_NAME],
		WaitingState.STATE_NAME : [MenuState.STATE_NAME, MoveState.STATE_NAME],
		MoveState.STATE_NAME : [WaitingState.STATE_NAME, WinState.STATE_NAME, DeadState.STATE_NAME],
		WinState.STATE_NAME : [MenuState.STATE_NAME, WaitingState.STATE_NAME],
		DeadState.STATE_NAME : [MenuState.STATE_NAME, WaitingState.STATE_NAME]
	}
	
	state_machine = StateMachine.new("level_state", transitions)
	
	menu_state = MenuState.new(state_machine)
	waiting_state = WaitingState.new(state_machine)
	move_state = MoveState.new(state_machine)
	win_state = WinState.new(state_machine)
	dead_state = DeadState.new(state_machine)
	
	state_machine.transition_to(menu_state)
	
func _input(event: InputEvent) -> void:
	for each in move_inputs.keys():
		if event.is_action_pressed(each):
			_request_movement(each)

func _request_movement(direction : InputEvent):
	pass
