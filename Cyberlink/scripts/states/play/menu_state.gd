extends BasePlayState
class_name MenuState

const STATE_NAME : String = "MENU_STATE"

signal signal_menu

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	camera.request_pose(Vector3(0,0,0),Vector3(0,0,0))
	
	signal_menu.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
