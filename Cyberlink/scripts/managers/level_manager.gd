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
@export var levels_dir := "res://scenes/levels"
@export var rat_node_path : String = "uid://drrs8ydypxlhr"

var active_rat : Rat
var move_inputs : Dictionary = {
	"ui_up" : false,
	"ui_down" : false,
	"ui_left" : false,
	"ui_right" : false
}

enum cam_dir {
	POSX,
	POSZ,
	NEGX,
	NEGZ
}

var active_cam_dir : cam_dir = cam_dir.POSX

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
			if state_machine.transition_to(move_state):
				active_rat._request_movement(event, active_cam_dir)


func _ready_level(level_number : int) -> void:
	if state_machine.current_state != menu_state:
		print("Invalid state to ready level. Currently in ", state_machine.current_state)
		return
	_load_level(level_number)

func _load_level(level_number : int) -> void:
	var path : String = "res://scenes/levels/level_%02d.tscn" % level_number
	
	if !ResourceLoader.exists(path):
		print("Level does not exist at: ", path)
		return
		
	var new_level : PackedScene = load(path)
	var new_level_instance : Node = new_level.instantiate()
	add_child(new_level_instance)
	_find_rat(new_level_instance)
	camera._hook_level_size(new_level_instance)
	camera._look_at_rat(active_cam_dir as int)
	
func _find_rat(level : Node) -> void:
	var new_rat : PackedScene = load(rat_node_path)
	var rat_instance = new_rat.instantiate()
	level.add_child(rat_instance)
	
	for child in level.get_children():
		if child is SpawnMarker:
			print("Found the rat here: ", child)
			rat_instance.global_position = child.global_position
			camera._hook_rat(rat_instance)
			return
