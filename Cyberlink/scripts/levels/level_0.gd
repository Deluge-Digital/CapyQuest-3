extends BaseLevel

@export var start_pos_x : int
@export var start_pos_z : int

@export var ground : Ground

func _ready() -> void:
	super.set_start_pos(start_pos_x, start_pos_z)
	super.generate_ground(ground)
