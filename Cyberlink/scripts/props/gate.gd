extends BaseProp
class_name Gate

@onready var left_door: MeshInstance3D = $Gate2/LeftDoor 
@onready var right_door: MeshInstance3D = $Gate2/RightDoor 

func _update_visibility() -> void:
	pass

func set_color():
	if tile_color == color_enum.TileColor.RED:
		var material : StandardMaterial3D = null
		var material2 : StandardMaterial3D = null
		if material == null:
			material = left_door.mesh.surface_get_material(0).duplicate()
			material2 = right_door.mesh.surface_get_material(0).duplicate()
			left_door.mesh.surface_set_material(0, material)
			right_door.mesh.surface_set_material(0, material)
		material2.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
		material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE:
		var material : StandardMaterial3D = null
		var material2 : StandardMaterial3D = null
		if material == null:
			material = left_door.mesh.surface_get_material(0).duplicate()
			material2 = right_door.mesh.surface_get_material(0).duplicate()
			left_door.mesh.surface_set_material(0, material)
			right_door.mesh.surface_set_material(0, material)
		material2.albedo_color = Color(0.017, 0.0, 1.0, 1.0)
		material.albedo_color = Color(0.017, 0.0, 1.0, 1.0)
	elif tile_color == color_enum.TileColor.GREEN:
		var material : StandardMaterial3D = null
		var material2 : StandardMaterial3D = null
		if material == null:
			material = left_door.mesh.surface_get_material(0).duplicate()
			material2 = right_door.mesh.surface_get_material(0).duplicate()
			left_door.mesh.surface_set_material(0, material)
			right_door.mesh.surface_set_material(0, material)
		material2.albedo_color = Color(0.117, 1.0, 0.0, 1.0)
		material.albedo_color = Color(0.117, 1.0, 0.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE_RED:
		var material : StandardMaterial3D = null
		if material == null:
			material = left_door.mesh.surface_get_material(0).duplicate()
			left_door.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.967, 0.0, 1.0, 1.0)
	elif tile_color == color_enum.TileColor.BLUE_GREEN:
		var material : StandardMaterial3D = null
		if material == null:
			material = left_door.mesh.surface_get_material(0).duplicate()
			left_door.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.0, 1.0, 0.95, 1.0)
	elif tile_color == color_enum.TileColor.GREEN_RED:
		var material : StandardMaterial3D = null
		if material == null:
			material = left_door.mesh.surface_get_material(0).duplicate()
			left_door.mesh.surface_set_material(0, material)
		material.albedo_color = Color(0.983, 1.0, 0.0, 1.0)

func _ready() -> void:
	set_color()
