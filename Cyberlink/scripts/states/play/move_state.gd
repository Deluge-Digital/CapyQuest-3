extends BasePlayState
class_name MoveState

const STATE_NAME : String = "MOVE_STATE"

signal signal_move

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	
	signal_move.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
