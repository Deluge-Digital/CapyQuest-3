extends BaseLevel

@export var start_pos_x : int
@export var start_pos_z : int


func _ready() -> void:
	super.set_start_pos(start_pos_x, start_pos_z)
