extends BaseProp
class_name Gate

@export var tile_color: color_enum.TileColor = color_enum.TileColor.NONE
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D



func set_color():
	if tile_color == color_enum.TileColor.RED:
		var material : StandardMaterial3D = null
		if material == null:
			material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
			mesh_instance_3d.mesh.surface_set_material(0, material)
		material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE:
		var material : StandardMaterial3D = null
		if material == null:
			material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
			mesh_instance_3d.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.0, 0.25, 1.0, 1.0)
	elif tile_color == color_enum.TileColor.GREEN:
		var material : StandardMaterial3D = null
		if material == null:
			material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
			mesh_instance_3d.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.017, 1.0, 0.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE_RED:
		var material : StandardMaterial3D = null
		if material == null:
			material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
			mesh_instance_3d.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.967, 0.0, 1.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE_GREEN:
		var material : StandardMaterial3D = null
		if material == null:
			material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
			mesh_instance_3d.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.0, 1.0, 0.95, 1.0)
	elif tile_color == color_enum.TileColor.GREEN_RED:
		var material : StandardMaterial3D = null
		if material == null:
			material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
			mesh_instance_3d.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.983, 1.0, 0.0, 1.0)

func _ready() -> void:
	set_color()
