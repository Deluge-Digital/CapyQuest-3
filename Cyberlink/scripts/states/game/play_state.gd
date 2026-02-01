extends State
class_name PlayState

const STATE_NAME : String = "PLAY_STATE"
const HUD_SCENE : PackedScene = preload("res://scenes/ui/pop_ups/hud.tscn")

signal signal_playing

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	GameManager.camera.request_pose(Vector3(-5,5,0),Vector3(-45,-90,0))
	GameManager.change_scene_deferred(HUD_SCENE)
	signal_playing.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
