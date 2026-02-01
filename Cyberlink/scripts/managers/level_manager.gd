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
	"up" : false,
	"down" : false,
	"left" : false,
	"right" : false
}

enum cam_dir {
	POSX,
	POSZ,
	NEGX,
	NEGZ
}

var current_level : int = 0
var current_level_node : Node
var rat_cam_mode : bool = true
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
		if event.is_action_pressed(each) && state_machine.current_state == waiting_state:
			if state_machine.transition_to(move_state):
				active_rat._request_movement(each, active_cam_dir)
				await get_tree().physics_frame
				await get_tree().physics_frame
				_update_camera()
	if event.is_action_pressed("camera_turn_left"):
		_turn_camera_left()
	if event.is_action_pressed("camera_turn_right"):
		_turn_camera_right()
	if event.is_action_pressed("camera_mode"):
		_change_rat_cam()
	if event.is_action_pressed("equip_red"):
		if PlayerData.get_mask_inventory() & color_enum.TileColor.RED:
			PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.RED) as color_enum.TileColor
			GameManager._update_color()
	if event.is_action_pressed("equip_green"):
		if PlayerData.get_mask_inventory() & color_enum.TileColor.GREEN:
			PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.GREEN) as color_enum.TileColor
			GameManager._update_color()
	if event.is_action_pressed("equip_blue"):
		if PlayerData.get_mask_inventory() & color_enum.TileColor.BLUE:
			PlayerData.player_color = (PlayerData.player_color ^ color_enum.TileColor.BLUE) as color_enum.TileColor
			GameManager._update_color()

func _refresh_level() -> void:
	if current_level_node:
		for each in current_level_node.get_children():
			if each is BaseProp:
				each._update_visibility()

func _turn_camera_left() -> void:
	match active_cam_dir:
		cam_dir.POSX: active_cam_dir = cam_dir.POSZ
		cam_dir.POSZ: active_cam_dir = cam_dir.NEGX
		cam_dir.NEGX: active_cam_dir = cam_dir.NEGZ
		cam_dir.NEGZ: active_cam_dir = cam_dir.POSX
	_update_camera()

func _turn_camera_right() -> void:
	match active_cam_dir:
		cam_dir.POSX: active_cam_dir = cam_dir.NEGZ
		cam_dir.POSZ: active_cam_dir = cam_dir.POSX
		cam_dir.NEGX: active_cam_dir = cam_dir.POSZ
		cam_dir.NEGZ: active_cam_dir = cam_dir.NEGX
	_update_camera()

func _change_rat_cam() -> void:
	rat_cam_mode = !rat_cam_mode
	_update_camera()

func _update_camera() -> void:
	if rat_cam_mode:
		camera._look_at_rat(active_cam_dir as int)
	else:
		camera._turn_level_camera(active_cam_dir as int)
	

func _reset_level() -> void:
	_load_level(current_level)

func _ready_level(level_number : int) -> void:
	if state_machine.current_state != menu_state:
		print("Invalid state to ready level. Currently in ", state_machine.current_state)
		return
	current_level = level_number
	_load_level(level_number)

func _load_level(level_number : int) -> void:
	var path : String = "res://scenes/levels/level_%02d.tscn" % level_number
	
	if !ResourceLoader.exists(path):
		print("Level does not exist at: ", path)
		return
		
	var new_level : PackedScene = load(path)
	var new_level_instance : Node = new_level.instantiate()
	current_level_node = new_level_instance
	
	add_child(new_level_instance)
	_find_rat(new_level_instance)
	camera._hook_level_size(new_level_instance)
	camera._look_at_rat(active_cam_dir as int)
	state_machine.transition_to(waiting_state)
	
func _find_rat(level : Node) -> void:
	var new_rat : PackedScene = load(rat_node_path)
	var rat_instance = new_rat.instantiate()
	level.add_child(rat_instance)
	active_rat = rat_instance
	
	for child in level.get_children():
		if child is SpawnMarker:
			print("Found the rat here: ", child)
			rat_instance.global_position = child.global_position
			camera._hook_rat(rat_instance)
			return

func request_waiting_state() -> bool:
	var success = state_machine.transition_to(waiting_state)
	return success
