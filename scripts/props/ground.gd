extends BaseProp
class_name Ground


@onready var mesh_instance_3d: MeshInstance3D = $Floor/Floor


func set_color():
	var material : StandardMaterial3D = null
	if material == null:
			material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
	if tile_color == color_enum.TileColor.RED:
		material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE:
		material.albedo_color = Color(0.0, 0.25, 1.0, 1.0)
	elif tile_color == color_enum.TileColor.GREEN:
		material.albedo_color = Color(0.017, 1.0, 0.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE_RED:
		material.albedo_color = Color(0.967, 0.0, 1.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE_GREEN:
		material.albedo_color = Color(0.0, 1.0, 0.95, 1.0)
	elif tile_color == color_enum.TileColor.GREEN_RED:
		material.albedo_color = Color(0.983, 1.0, 0.0, 1.0)
	mesh_instance_3d.mesh.surface_set_material(0, material)


func _ready() -> void:
	pass #set_color()
